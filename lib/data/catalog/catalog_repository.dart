/// @title CatalogRepository
/// @notice Offline-first catalogue: cached products, sellers, and favorites.
/// @dev Reads come from Drift streams so screens follow the cache; refreshes
/// pull `/api/products`, `/api/users/:id` and `/api/favorites` into it
/// (`postman/specs/tables/products.md`, `favorites.md`). A failed refresh
/// leaves the last good cache on screen, which is the offline behaviour.
/// @author Kosply-mobile
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/database/daos/catalog_dao.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/cache_marker.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/json_read.dart';
import '../../models/catalog/product.dart';
import '../../models/catalog/product_stats.dart';
import '../../models/catalog/seller.dart';
import '../shared/price_labels.dart';
import '../shared/time_labels.dart';

/// @title NewListing
/// @notice Fields the add-product form posts to `POST /api/products`.
class NewListing {
  /// @notice Creates the listing payload.
  /// @param title Item name.
  /// @param description Item description.
  /// @param category Free-text category.
  /// @param price Integer rupiah.
  /// @param stock Units available.
  /// @param imageUrls Uploaded photo URLs, cover first.
  /// @param locationLabel Meeting point.
  /// @param latitude Pin for [locationLabel], when the seller picked one.
  /// @param longitude Pin for [locationLabel], when the seller picked one.
  /// @param includeCoordinates When true, [latitude] and [longitude] are
  /// written even if they are null, so an edited label can drop a stale pin.
  /// @return A new {NewListing} instance.
  const NewListing({
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrls,
    this.locationLabel = '',
    this.latitude,
    this.longitude,
    this.includeCoordinates = false,
  });

  /// @dev Item name.
  final String title;

  /// @dev Item description.
  final String description;

  /// @dev Free-text category.
  final String category;

  /// @dev Integer rupiah.
  final int price;

  /// @dev Units available.
  final int stock;

  /// @dev Uploaded photo URLs, cover first.
  final List<String> imageUrls;

  /// @dev Meeting point.
  final String locationLabel;

  /// @dev Pin latitude. Null when the seller did not pick a place.
  final double? latitude;

  /// @dev Pin longitude. Null when the seller did not pick a place.
  final double? longitude;

  /// @dev Whether [latitude] and [longitude] are part of the payload.
  final bool includeCoordinates;
}

/// @title CatalogRepository
/// @notice Reactive catalogue access for every product-facing screen.
class CatalogRepository {
  /// @notice Creates the repository.
  /// @param dao Drift access to the catalogue cache.
  /// @param api Backend client.
  /// @return A new {CatalogRepository} instance.
  CatalogRepository({required this.dao, required this.api});

  /// @dev Drift access to the catalogue cache.
  final CatalogDao dao;

  /// @dev Backend client.
  final ApiClient api;

  /// @dev Largest page the catalogue endpoint serves.
  static const int pageSize = 50;

  /// @notice Replaces the cached catalogue with `GET /api/products`.
  /// @return Future completing when the transaction is durable.
  Future<void> refresh() async {
    final Map<String, dynamic> json = await api.get(
      '/api/products',
      query: <String, String>{'limit': '$pageSize'},
      auth: false,
    );
    final List<Map<String, dynamic>> items = json.objects('items');
    final int now = utcMillisNow();
    await dao.replaceCatalog(
      userRows: _sellerRows(items, now),
      productRows: <ProductsCompanion>[
        for (final Map<String, dynamic> item in items) _productRow(item, now),
      ],
      fetchedAt: now,
    );
  }

  /// @notice Pulls one product's detail (description, status) into the cache.
  /// @param id Product id.
  /// @return Future completing when the row is durable.
  Future<void> refreshProduct(String id) async {
    final Map<String, dynamic> json = await api.get(
      '/api/products/$id',
      auth: false,
    );
    final Map<String, dynamic> item =
        json.object('item') ?? const <String, dynamic>{};
    final int now = utcMillisNow();
    await dao.upsertCatalog(
      userRows: _sellerRows(<Map<String, dynamic>>[item], now),
      productRows: <ProductsCompanion>[_productRow(item, now, detail: true)],
    );
  }

  /// @notice Pulls a seller's profile and shelf into the cache.
  /// @param sellerId Backend `users.id`.
  /// @return Future completing when both are durable.
  Future<void> refreshSeller(String sellerId) async {
    final Map<String, dynamic> profile = await api.get(
      '/api/users/$sellerId',
      auth: false,
    );
    final Map<String, dynamic> shelf = await api.get(
      '/api/products',
      query: <String, String>{'sellerId': sellerId, 'limit': '$pageSize'},
      auth: false,
    );
    final int now = utcMillisNow();
    final List<Map<String, dynamic>> items = shelf.objects('items');
    await dao.upsertCatalog(
      userRows: <UsersCompanion>[
        ..._sellerRows(items, now),
        _userRow(profile.object('item') ?? const <String, dynamic>{}, now),
      ],
      productRows: <ProductsCompanion>[
        for (final Map<String, dynamic> item in items) _productRow(item, now),
      ],
    );
  }

  /// @notice Replaces the saved list with `GET /api/favorites`.
  /// @return Future completing when the cache matches the server.
  Future<void> refreshFavorites() async {
    final Map<String, dynamic> json = await api.get('/api/favorites');
    final List<Map<String, dynamic>> items = json.objects('items');
    final int now = utcMillisNow();
    await dao.upsertCatalog(
      userRows: _sellerRows(items, now),
      productRows: <ProductsCompanion>[
        for (final Map<String, dynamic> item in items) _productRow(item, now),
      ],
    );
    // The server lists newest save first; the cache orders by save time, so
    // older saves get the smaller stamps.
    await dao.replaceFavorites(
      productIds: <String>[
        for (final Map<String, dynamic> item in items) item.str('id'),
      ],
      savedAt: <int>[for (int i = 0; i < items.length; i++) now - i],
    );
  }

  /// @notice Streams every cached product with its seller attached.
  /// @return Stream of products in backend order.
  Stream<List<Product>> watchProducts() {
    return dao.watchProductsWithSeller().map(_toProducts);
  }

  /// @notice Streams one cached product with its seller attached.
  /// @param id Identifier taken from {Products.id}.
  /// @return Stream of the product, or null when not cached.
  Stream<Product?> watchProduct(String id) {
    return dao.watchProductWithSeller(id).map((ProductWithSeller? pair) {
      if (pair == null) {
        return null;
      }
      return _toProduct(pair.$1, pair.$2);
    });
  }

  /// @notice Streams the listings of one seller.
  /// @param sellerId Identifier taken from {Users.id}.
  /// @return Stream of products in backend order.
  Stream<List<Product>> watchProductsBySeller(String sellerId) {
    return dao.watchSellerProductsWithSeller(sellerId).map(_toProducts);
  }

  /// @notice Streams the saved products.
  /// @return Stream of products in save order.
  Stream<List<Product>> watchFavoriteProducts() {
    return dao.watchFavoriteProductsWithSeller().map(_toProducts);
  }

  /// @notice Streams the saved favorite ids.
  /// @return Stream of product ids, oldest saved first.
  Stream<Set<String>> watchFavoriteIds() {
    return dao.watchFavoriteIds();
  }

  /// @notice Streams one cached seller.
  /// @param sellerId Identifier taken from {Users.id}.
  /// @return Stream of the seller, or null when not cached.
  Stream<Seller?> watchSeller(String sellerId) {
    return dao.watchUser(sellerId).map(_toSeller);
  }

  /// @notice Saves or unsaves a product, optimistic first.
  /// @dev The heart flips in the cache immediately; the `PUT`/`DELETE` then
  /// confirms it, and a refusal flips it back before rethrowing.
  /// @param productId Catalogue item id.
  /// @return Future completing when the server agreed.
  Future<void> toggleFavorite(String productId) async {
    final bool saved = !(await dao.isFavorite(productId));
    await dao.setFavorite(
      productId: productId,
      saved: saved,
      createdAt: utcMillisNow(),
    );
    try {
      if (saved) {
        await api.put('/api/favorites/$productId');
      } else {
        await api.delete('/api/favorites/$productId');
      }
    } on ApiException {
      await dao.setFavorite(
        productId: productId,
        saved: !saved,
        createdAt: utcMillisNow(),
      );
      rethrow;
    }
  }

  /// @notice Active product categories in display order.
  /// @return Names the add-product dropdown can select.
  Future<List<String>> categories() async {
    final Map<String, dynamic> json = await api.get(
      '/api/categories',
      auth: false,
    );
    return <String>[
      for (final Map<String, dynamic> item in json.objects('items'))
        if (item.str('name').isNotEmpty) item.str('name'),
    ];
  }

  /// @notice Posts a new listing and caches the server's copy.
  /// @param listing Form fields.
  /// @return The new product id.
  Future<String> createListing(NewListing listing) async {
    final Map<String, dynamic> json = await api.post(
      '/api/products',
      body: <String, Object?>{
        'title': listing.title,
        'description': listing.description,
        'category': listing.category,
        'price': listing.price,
        'stock': listing.stock,
        'imageUrls': listing.imageUrls,
        if (listing.locationLabel.isNotEmpty)
          'locationLabel': listing.locationLabel,
        if (listing.includeCoordinates) ...<String, Object?>{
          'latitude': listing.latitude,
          'longitude': listing.longitude,
        },
      },
    );
    final Map<String, dynamic> item =
        json.object('item') ?? const <String, dynamic>{};
    final int now = utcMillisNow();
    await dao.upsertCatalog(
      userRows: _sellerRows(<Map<String, dynamic>>[item], now),
      productRows: <ProductsCompanion>[_productRow(item, now, detail: true)],
    );
    return item.str('id');
  }

  /// @notice Updates an active listing the signed-in seller owns.
  /// @param id Product id.
  /// @param listing Fields to write. Omitted empties are still sent when
  /// the caller includes them.
  /// @return Future completing when the cache holds the server copy.
  Future<void> updateListing(String id, NewListing listing) async {
    final Map<String, dynamic> json = await api.patch(
      '/api/products/$id',
      body: <String, Object?>{
        'title': listing.title,
        'description': listing.description,
        'category': listing.category,
        'price': listing.price,
        'stock': listing.stock,
        'imageUrls': listing.imageUrls,
        'locationLabel': listing.locationLabel,
        if (listing.includeCoordinates) ...<String, Object?>{
          'latitude': listing.latitude,
          'longitude': listing.longitude,
        },
      },
    );
    await _writeProduct(json.object('item') ?? const <String, dynamic>{});
  }

  /// @notice Archives a listing. History stays on the server; the card leaves
  /// the phone catalogue.
  /// @param id Product id.
  /// @return Future completing when the local row is gone.
  Future<void> archiveListing(String id) async {
    await api.delete('/api/products/$id');
    await dao.removeProduct(id);
  }

  /// @notice Marks a listing sold and drops it from the public catalogue cache.
  /// @param id Product id.
  /// @return Future completing when the local row is gone.
  Future<void> markSold(String id) async {
    await api.patch('/api/products/$id/sold');
    await dao.removeProduct(id);
  }

  /// @notice Records one catalogue event. Failures are swallowed: a missed
  /// impression must not break the feed.
  /// @param productId Product id.
  /// @param type `IMPRESSION` or `CLICK`.
  /// @param source `feed`, `search`, `detail`, `share`, or `unknown`.
  /// @return Future completing when the call settled.
  Future<void> recordEvent(
    String productId,
    String type, {
    required String source,
  }) async {
    try {
      await api.post(
        '/api/analytics/products/$productId/event',
        query: <String, String>{'type': type, 'source': source},
      );
    } on ApiException {
      return;
    }
  }

  /// @notice Reads one product's analytics. Owner or staff only.
  /// @param productId Product id.
  /// @return The stats row.
  Future<ProductStats> productStats(String productId) async {
    final Map<String, dynamic> json = await api.get(
      '/api/analytics/products/$productId',
      query: <String, String>{'days': '30'},
    );
    return ProductStats.fromJson(
      json.object('item') ?? const <String, dynamic>{},
    );
  }

  Future<void> _writeProduct(Map<String, dynamic> item) async {
    final int now = utcMillisNow();
    await dao.upsertCatalog(
      userRows: _sellerRows(<Map<String, dynamic>>[item], now),
      productRows: <ProductsCompanion>[_productRow(item, now, detail: true)],
    );
  }

  /// @notice Maps a backend product to a cache row.
  /// @dev A list card has no description or status; leaving them absent
  /// keeps what an earlier detail fetch stored.
  /// @param item Backend product.
  /// @param now Cache stamp.
  /// @param detail Whether [item] came from a detail or write response.
  /// @return The companion.
  ProductsCompanion _productRow(
    Map<String, dynamic> item,
    int now, {
    bool detail = false,
  }) {
    final Map<String, dynamic>? seller = item.object('seller');
    return ProductsCompanion(
      id: Value<String>(item.str('id')),
      sellerId: Value<String>(seller?.str('id') ?? item.str('sellerId')),
      title: Value<String>(item.str('title')),
      description: detail || item.containsKey('description')
          ? Value<String>(item.str('description'))
          : const Value<String>.absent(),
      price: Value<int>(item.integer('price')),
      stock: Value<int>(item.integer('stock')),
      imageUrls: Value<String>(jsonEncode(item.strings('imageUrls'))),
      category: Value<String>(item.str('category')),
      latitude: Value<double>(item.real('latitude')),
      longitude: Value<double>(item.real('longitude')),
      locationLabel: Value<String>(item.str('locationLabel')),
      status: item.containsKey('status')
          ? Value<String>(item.str('status'))
          : const Value<String>.absent(),
      createdAt: item.containsKey('createdAt')
          ? Value<int>(item.millis('createdAt'))
          : const Value<int>.absent(),
      backendUpdatedAt: _backendStamp(item),
      updatedAt: Value<int>(now),
      lastFetched: Value<int>(now),
    );
  }

  /// @notice Backend stamp used to order the catalogue.
  /// @dev List cards often carry `createdAt` and no later `updatedAt`. A
  /// missing stamp stays absent so a detail fetch is not wiped back to zero.
  /// @param item Backend product.
  /// @return The stamp, or absent.
  Value<int> _backendStamp(Map<String, dynamic> item) {
    if (!item.containsKey('updatedAt') && !item.containsKey('createdAt')) {
      return const Value<int>.absent();
    }
    final int updated = item.millis('updatedAt');
    return Value<int>(updated == 0 ? item.millis('createdAt') : updated);
  }

  /// @notice Collects the distinct sellers attached to [items].
  /// @param items Backend products.
  /// @param now Cache stamp.
  /// @return One companion per seller.
  List<UsersCompanion> _sellerRows(List<Map<String, dynamic>> items, int now) {
    final Map<String, UsersCompanion> rows = <String, UsersCompanion>{};
    for (final Map<String, dynamic> item in items) {
      final Map<String, dynamic>? seller = item.object('seller');
      if (seller != null && seller.str('id').isNotEmpty) {
        rows[seller.str('id')] = _userRow(seller, now);
      }
    }
    return rows.values.toList();
  }

  /// @notice Maps a public backend user to a cache row.
  /// @dev Only the public columns present are written: a card's seller has no
  /// bio, and must not blank one a profile fetch stored. `isMe` is never set
  /// here, so the signed-in profile row keeps its flag.
  /// @param user Public user.
  /// @param now Cache stamp.
  /// @return The companion.
  UsersCompanion _userRow(Map<String, dynamic> user, int now) {
    Value<String> optional(String key) => user.containsKey(key)
        ? Value<String>(user.str(key))
        : const Value<String>.absent();
    return UsersCompanion(
      id: Value<String>(user.str('id')),
      username: optional('username'),
      name: optional('name'),
      bio: optional('bio'),
      photo: optional('photo'),
      universitas: optional('universitas'),
      programStudi: optional('programStudi'),
      role: optional('role'),
      backendUpdatedAt: _activityStamp(user),
      updatedAt: Value<int>(now),
      lastFetched: Value<int>(now),
    );
  }

  List<Product> _toProducts(List<ProductWithSeller> rows) {
    return <Product>[
      for (final ProductWithSeller row in rows) _toProduct(row.$1, row.$2),
    ];
  }

  Product _toProduct(ProductRow row, UserRow? seller) {
    final List<String> images = _decodeImages(row);
    return Product(
      id: row.id,
      title: row.title,
      price: priceLabel(row.price),
      location: row.locationLabel,
      imagePath: images.isEmpty ? Product.placeholderImage : images.first,
      quantity: row.stock,
      category: row.category,
      description: row.description,
      gallery: images.isEmpty
          ? const <String>[Product.placeholderImage]
          : images,
      sellerId: row.sellerId,
      sellerName: seller?.name ?? '',
      sellerAvatarPath: seller?.photo ?? '',
      sellerActiveLabel: seller == null ? '' : _activityOf(seller),
      latitude: row.latitude,
      longitude: row.longitude,
    );
  }

  Seller? _toSeller(UserRow? row) {
    if (row == null) {
      return null;
    }
    return Seller(
      id: row.id,
      name: row.name,
      avatarPath: row.photo,
      activeLabel: _activityOf(row),
      bio: row.bio,
    );
  }

  /// @notice Activity time from a public user, when the payload has one.
  /// @param user Backend user.
  /// @return The stamp, or absent so a later profile fetch is not wiped to zero.
  Value<int> _activityStamp(Map<String, dynamic> user) {
    final int updated = user.millis('updatedAt');
    final int seen = user.millis('lastSeenAt');
    final int stamp = updated == 0 ? seen : updated;
    return stamp == 0 ? const Value<int>.absent() : Value<int>(stamp);
  }

  /// @notice "aktif ... lalu" when the backend sent an activity time.
  /// @dev Public user payloads carry no timestamp, and a zero stamp used to
  /// read as "aktif 20000 hari lalu".
  /// @param row Cached user.
  /// @return The label, or empty.
  String _activityOf(UserRow row) {
    return row.backendUpdatedAt == 0
        ? ''
        : activityLabelFor(row.backendUpdatedAt);
  }

  List<String> _decodeImages(ProductRow row) {
    try {
      final Object? decoded = jsonDecode(row.imageUrls);
      if (decoded is List) {
        return <String>[
          for (final Object? item in decoded)
            if (item is String && item.isNotEmpty) item,
        ];
      }
    } on FormatException {
      return const <String>[];
    }
    return const <String>[];
  }
}
