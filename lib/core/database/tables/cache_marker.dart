/// @title Cache marker
/// @notice Columns every cached-from-backend table shares.
/// @dev Stores UTC milliseconds so the data layer can tell when a row was
/// last refreshed from the server.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

/// @title CacheMarker
/// @notice Adds `updated_at` and `last_fetched` to a table.
/// @dev Both are UTC millis. `lastFetched` is stamped when a refresh writes
/// the whole table; `updatedAt` is stamped whenever the row changes.
mixin CacheMarker on Table {
  /// @dev UTC millis of the last write to this row.
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  /// @dev UTC millis of the last successful backend refresh.
  IntColumn get lastFetched => integer().withDefault(const Constant(0))();
}

/// @notice Current time as UTC milliseconds since epoch.
/// @return The cache-marker timestamp for a new write.
int utcMillisNow() => DateTime.now().toUtc().millisecondsSinceEpoch;
