/// @title CatalogRepository
/// @notice Offline-first catalogue: cached products, sellers, and favorites.
/// @dev Reads come from Drift streams so screens follow the cache; writes go
/// through {CatalogDao} transactions. Until the product API lands, the
/// placeholder catalogue acts as the stand-in remote that fills the cache.
/// @author Kosply-mobile
library;

import 'dart:convert';

import '../../core/database/daos/catalog_dao.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/cache_marker.dart';
import '../../models/catalog/product.dart';
import '../../models/catalog/seller.dart';
import '../shared/price_labels.dart';
import '../shared/time_labels.dart';
import 'placeholder_catalog.dart';

/// @title CatalogRepository
/// @notice Reactive catalogue access for every product-facing screen.
class CatalogRepository {
  /// @notice Creates the repository.
  /// @param dao Drift access to the catalogue cache.
  /// @return A new {CatalogRepository} instance.
  CatalogRepository({required this.dao});

  /// @dev Drift access to the catalogue cache.
  final CatalogDao dao;

  /// @notice Fills the cache when it has never been synced.
  /// @return Future completing when the cache is ready.
  Future<void> ensureSeeded() async {
    if (await dao.isProductCacheEmpty()) {
      await refresh();
    }
  }

  /// @notice Replaces the cache with a fresh remote payload.
  /// @dev The placeholder catalogue stands in for the future `GET /products`
  /// response; swapping this body for an HTTP call keeps the write path.
  /// @return Future completing when the transaction is durable.
  Future<void> refresh() async {
    final int now = utcMillisNow();
    await dao.replaceCatalog(
      userRows: PlaceholderCatalog.userRows(now: now),
      productRows: PlaceholderCatalog.productRows(now: now),
      fetchedAt: now,
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

  /// @notice Adds or removes a saved product.
  /// @param productId Catalogue item id.
  /// @return Future completing when the toggle is durable.
  Future<void> toggleFavorite(String productId) {
    return dao.toggleFavorite(
      productId: productId,
      createdAt: utcMillisNow(),
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
      sellerActiveLabel: seller == null
          ? ''
          : activityLabelFor(seller.backendUpdatedAt),
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
      activeLabel: activityLabelFor(row.backendUpdatedAt),
      bio: row.bio,
    );
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
