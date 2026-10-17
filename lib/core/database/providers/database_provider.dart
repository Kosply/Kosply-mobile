/// @title Database provider
/// @notice Exposes the Drift database to Riverpod consumers.
/// @dev Defaults to an in-memory database so widget tests need no overrides;
/// the app entry point overrides it with the file-backed instance.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';

/// @dev Local persistence for cached backend data.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final AppDatabase database = AppDatabase.memory();
  ref.onDispose(database.close);
  return database;
});
