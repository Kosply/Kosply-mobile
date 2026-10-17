/// @title Catalog tables
/// @notice Local cache for products and saved favorites.
/// @dev Product columns mirror the backend `products` table so an API refresh
/// can be written straight into the cache with no schema change.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import 'cache_marker.dart';

/// @title Products
/// @notice Cached catalogue items served by every product screen.
@DataClassName('ProductRow')
class Products extends Table with CacheMarker {
  /// @dev Stable identifier from the backend.
  TextColumn get id => text()();

  /// @dev Identifier of the student selling the item.
  TextColumn get sellerId => text().withDefault(const Constant(''))();

  /// @dev Item name.
  TextColumn get title => text()();

  /// @dev Long description text.
  TextColumn get description => text().withDefault(const Constant(''))();

  /// @dev Price in rupiah, integer as stored by the backend.
  IntColumn get price => integer().withDefault(const Constant(0))();

  /// @dev Units still available.
  IntColumn get stock => integer().withDefault(const Constant(1))();

  /// @dev JSON-encoded image URLs.
  TextColumn get imageUrls => text().withDefault(const Constant('[]'))();

  /// @dev Category label.
  TextColumn get category => text().withDefault(const Constant(''))();

  /// @dev Meeting-point latitude.
  RealColumn get latitude => real().withDefault(const Constant(0))();

  /// @dev Meeting-point longitude.
  RealColumn get longitude => real().withDefault(const Constant(0))();

  /// @dev Human-readable location label.
  TextColumn get locationLabel => text().withDefault(const Constant(''))();

  /// @dev ACTIVE, SOLD or ARCHIVED.
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))();

  /// @dev UTC millis when the item was sold; 0 when still active.
  IntColumn get soldAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis when the backend created the listing.
  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis of the last backend update to the row.
  IntColumn get backendUpdatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// @title Favorites
/// @notice Product ids saved from the product-detail heart.
@DataClassName('FavoriteRow')
class Favorites extends Table {
  /// @dev Saved catalogue item id.
  TextColumn get productId => text()();

  /// @dev UTC millis when the item was saved.
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{productId};
}
