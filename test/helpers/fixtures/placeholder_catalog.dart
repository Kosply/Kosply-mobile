/// @title PlaceholderCatalog
/// @notice Stand-in catalogue used until the product API is wired up.
/// @dev Keeps the id-to-product lookup in one place so screens only ever hold
/// an id, which is what the detail route is meant to receive. Also builds the
/// seed rows the offline-first cache is filled with on first launch.
/// @author Kosply-mobile
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:kosply_mobile/core/database/app_database.dart';
import 'package:kosply_mobile/models/catalog/product.dart';
import 'package:kosply_mobile/models/catalog/seller.dart';

/// @title PlaceholderCatalog
/// @notice Fake data source for the home feed, detail screen and reviews.
class PlaceholderCatalog {
  // @dev Prevents instantiation of this utility holder.
  const PlaceholderCatalog._();

  /// @dev Number of placeholder products.
  /// @dev Four sellers times four listings keeps every catalogue grid even.
  static const int productCount = 16;

  /// @dev Number of placeholder sellers.
  static const int sellerCount = 4;

  static const String _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut '
      'enim ad minim veniam, quis nostrud exercitation ullamco laboris '
      'nisi ut aliquip ex ea commodo consequat.';

  static const List<String> _titles = <String>[
    'Meja belajar lipat',
    'Kipas angin meja',
    'Rice cooker 1.8L',
    'Kasur busa single',
    'Lampu belajar LED',
    'Rak sepatu 4 susun',
    'Dispenser galon',
    'Jemuran baju lipat',
    'Speaker bluetooth',
    'Setrika uap',
    'Panci stainless',
    'Kursi lipat kampus',
    'Bantal guling',
    'Galon air 19L',
    'Gorden jendela kos',
    'Karpet lantai 2x1',
  ];

  static const List<String> _categories = <String>[
    'Kamar',
    'Dapur Kos',
    'Elektronik',
    'Belajar',
    'Hobi',
    'Pindahan',
  ];

  static const List<String> _prices = <String>[
    'Rp.375.000',
    'Rp.1.250.000',
    'Rp.80.000',
    'Rp.2.400.000',
    'Rp.150.000',
    'Rp.650.000',
    'Rp.990.000',
    'Rp.45.000',
    'Rp.3.100.000',
    'Rp.220.000',
    'Rp.780.000',
    'Rp.1.875.000',
    'Rp.175.000',
    'Rp.55.000',
    'Rp.90.000',
    'Rp.320.000',
  ];

  /// @notice One fixture seller, wrapped across {sellerCount}.
  /// @param index Zero-based seller slot.
  /// @return The seller used by the fake catalogue and inbox.
  static Seller sellerAt(int index) {
    final int slot = index % sellerCount;
    final int minutes = (slot * 11) + 5;
    return Seller(
      id: 'seller-${slot + 1}',
      name: 'seller${slot + 1}',
      avatarPath: Seller.avatar,
      activeLabel: 'aktif $minutes menit lalu',
      bio: _lorem,
    );
  }

  /// @notice Minutes-ago label baked into {sellerAt}.
  /// @param index Zero-based seller slot.
  /// @return Minutes since that fixture seller was last active.
  static int activeMinutes(int index) {
    final int slot = index % sellerCount;
    return (slot * 11) + 5;
  }

  /// @notice One fixture product.
  /// @param index Position in the catalogue.
  /// @return The product.
  static Product productAt(int index) {
    final Seller seller = sellerAt(index);
    return Product(
      id: 'product-$index',
      title: _titles[index % _titles.length],
      price: _prices[index % _prices.length],
      location: 'Dekat gedung a',
      imagePath: Product.placeholderImage,
      quantity: index % 3 + 1,
      category: _categories[index % _categories.length],
      description: _lorem,
      gallery: List<String>.filled(
        5,
        Product.placeholderImage,
        growable: false,
      ),
      sellerId: seller.id,
      sellerName: seller.name,
      sellerAvatarPath: seller.avatarPath,
      sellerActiveLabel: seller.activeLabel,
    );
  }

  /// @notice All placeholder products.
  /// @return The catalogue as a list.
  static List<Product> all() {
    return List<Product>.generate(productCount, productAt);
  }

  /// @notice Builds the seller rows seeded into the local cache.
  /// @dev Activity offsets match the placeholder "aktif N menit lalu" labels
  /// so the mapped seller keeps the same copy.
  /// @param now UTC millis used as the reference time.
  /// @return User companions for the four placeholder sellers.
  static List<UsersCompanion> userRows({required int now}) {
    return <UsersCompanion>[
      for (int i = 0; i < sellerCount; i++)
        _userRow(
          sellerAt(i),
          now: now,
          activeMinutes: activeMinutes(i),
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
    for (int i = 0; i < sellerCount; i++) {
      final Seller seller = sellerAt(i);
      if (seller.id == id) {
        return seller;
      }
    }
    return sellerAt(0);
  }

  /// @notice Catalogue items listed by one seller.
  /// @param sellerId Identifier taken from [Seller.id].
  /// @return The seller's products in catalogue order.
  static List<Product> productsBySeller(String sellerId) {
    return all().where((Product item) => item.sellerId == sellerId).toList();
  }
}
