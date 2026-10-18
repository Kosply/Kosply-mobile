/// @title PlaceholderCatalog
/// @notice Stand-in catalogue used until the product API is wired up.
/// @dev Keeps the id-to-product lookup in one place so screens only ever hold
/// an id, which is what the detail route is meant to receive. Also builds the
/// seed rows the offline-first cache is filled with on first launch.
/// @author Kosply-mobile
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../models/catalog/product.dart';
import '../../models/catalog/seller.dart';

/// @title PlaceholderCatalog
/// @notice Fake data source for the home feed, detail screen and reviews.
class PlaceholderCatalog {
  // @dev Prevents instantiation of this utility holder.
  const PlaceholderCatalog._();

  /// @dev Number of placeholder products.
  /// @dev Four sellers times four listings keeps every catalogue grid even.
  static const int productCount = 16;

  /// @notice All placeholder products.
  /// @return The catalogue as a list.
  static List<Product> all() {
    return List<Product>.generate(productCount, Product.placeholder);
  }

  /// @notice Builds the seller rows seeded into the local cache.
  /// @dev Activity offsets match the placeholder "aktif N menit lalu" labels
  /// so the mapped seller keeps the same copy.
  /// @param now UTC millis used as the reference time.
  /// @return User companions for the four placeholder sellers.
  static List<UsersCompanion> userRows({required int now}) {
    return <UsersCompanion>[
      for (int i = 0; i < Seller.count; i++)
        _userRow(
          Seller.placeholder(i),
          now: now,
          activeMinutes: Seller.placeholderActiveMinutes(i),
        ),
    ];
  }

  /// @notice Builds the product rows seeded into the local cache.
  /// @dev Stamps descending `backendUpdatedAt` values so the cached order
  /// matches the placeholder catalogue order.
  /// @param now UTC millis used as the reference time.
  /// @return Product companions for the placeholder catalogue.
  static List<ProductsCompanion> productRows({required int now}) {
    final List<Product> items = all();
    return <ProductsCompanion>[
      for (int i = 0; i < items.length; i++)
        _productRow(items[i], now: now - (i * 60000)),
    ];
  }

  static UsersCompanion _userRow(
    Seller seller, {
    required int now,
    required int activeMinutes,
  }) {
    return UsersCompanion.insert(
      id: seller.id,
      username: Value<String>(seller.name),
      name: Value<String>(seller.name),
      bio: Value<String>(seller.bio),
      photo: Value<String>(seller.avatarPath),
      role: const Value<String>('SELLER'),
      isActive: const Value<bool>(true),
      createdAt: Value<int>(now),
      backendUpdatedAt: Value<int>(now - (activeMinutes * 60000)),
      updatedAt: Value<int>(now),
      lastFetched: Value<int>(now),
    );
  }

  static ProductsCompanion _productRow(Product item, {required int now}) {
    return ProductsCompanion.insert(
      id: item.id,
      title: item.title,
      sellerId: Value<String>(item.sellerId),
      description: Value<String>(item.description),
      price: Value<int>(item.priceValue),
      stock: Value<int>(item.quantity),
      imageUrls: Value<String>(jsonEncode(<String>[item.imagePath])),
      category: Value<String>(item.category),
      locationLabel: Value<String>(item.location),
      status: const Value<String>('ACTIVE'),
      createdAt: Value<int>(now),
      backendUpdatedAt: Value<int>(now),
      updatedAt: Value<int>(now),
      lastFetched: Value<int>(now),
    );
  }

  /// @notice Looks a product up by id.
  /// @dev Falls back to the first entry so a bad id still renders a screen
  /// @dev instead of throwing.
  /// @param id Identifier taken from [Product.id].
  /// @return The matching product, or a fallback.
  static Product byId(String id) {
    final List<Product> items = all();
    for (final Product item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return items.first;
  }

  /// @notice Looks a seller up by id.
  /// @dev Falls back to the first seller so a bad id still renders a screen.
  /// @param id Identifier taken from [Seller.id].
  /// @return The matching seller, or a fallback.
  static Seller sellerById(String id) {
    for (int i = 0; i < Seller.count; i++) {
      final Seller seller = Seller.placeholder(i);
      if (seller.id == id) {
        return seller;
      }
    }
    return Seller.placeholder(0);
  }

  /// @notice Catalogue items listed by one seller.
  /// @param sellerId Identifier taken from [Seller.id].
  /// @return The seller's products in catalogue order.
  static List<Product> productsBySeller(String sellerId) {
    return all().where((Product item) => item.sellerId == sellerId).toList();
  }
}
