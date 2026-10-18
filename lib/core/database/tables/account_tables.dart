/// @title Account tables
/// @notice Local cache for public user profiles (sellers and the account).
/// @dev Mirrors the backend `users` projection the API returns: secrets such
/// as passwordHash, googleId and appleId are never cached on device.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import 'cache_marker.dart';

/// @title Users
/// @notice Cache of public user rows from the backend.
@DataClassName('UserRow')
class Users extends Table with CacheMarker {
  /// @dev Stable identifier from the backend.
  TextColumn get id => text()();

  /// @dev Campus email; only filled for the signed-in account.
  TextColumn get email => text().withDefault(const Constant(''))();

  /// @dev Handle shown on the marketplace.
  TextColumn get username => text().withDefault(const Constant(''))();

  /// @dev Display name.
  TextColumn get name => text().withDefault(const Constant(''))();

  /// @dev Seller bio; empty for buyers.
  TextColumn get bio => text().withDefault(const Constant(''))();

  /// @dev URL of the profile photo.
  TextColumn get photo => text().withDefault(const Constant(''))();

  /// @dev Campus name.
  TextColumn get universitas => text().withDefault(const Constant(''))();

  /// @dev Study program.
  TextColumn get programStudi => text().withDefault(const Constant(''))();

  /// @dev BUYER, SELLER or ADMIN.
  TextColumn get role => text().withDefault(const Constant('BUYER'))();

  /// @dev Whether the account is active on the backend.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// @dev Local-only marker for the signed-in account's row.
  BoolColumn get isMe => boolean().withDefault(const Constant(false))();

  /// @dev UTC millis when the backend created the account.
  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis of the last backend update to the row.
  IntColumn get backendUpdatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
