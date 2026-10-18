/// @title AppDatabase
/// @notice Drift database that backs the offline-first data layer.
/// @dev Every cached backend table carries {CacheMarker} columns and is only
/// written through DAO transactions, so refreshes are atomic.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/account_dao.dart';
import 'daos/ai_chat_dao.dart';
import 'daos/catalog_dao.dart';
import 'daos/inbox_dao.dart';
import 'daos/support_dao.dart';
import 'tables/account_tables.dart';
import 'tables/ai_tables.dart';
import 'tables/catalog_tables.dart';
import 'tables/inbox_tables.dart';
import 'tables/support_tables.dart';

part 'app_database.g.dart';

/// @title AppDatabase
/// @notice Owns every local table and DAO of the marketplace app.
@DriftDatabase(
  tables: <Type>[
    Users,
    Products,
    Favorites,
    Conversations,
    Messages,
    HelpTopics,
    SupportTickets,
    SupportMessages,
    AiConversations,
    AiMessages,
  ],
  daos: <Type>[CatalogDao, InboxDao, SupportDao, AiChatDao, AccountDao],
)
class AppDatabase extends _$AppDatabase {
  /// @notice Opens the database with a caller-supplied executor.
  /// @param e Executor, file-backed in the app and in-memory in tests.
  /// @return A new {AppDatabase} instance.
  AppDatabase(super.e);

  /// @notice Opens an isolated in-memory database.
  /// @return A throwaway {AppDatabase} for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  /// @notice Opens the on-device database file.
  /// @return Executor for the platform documents directory.
  static QueryExecutor openDefault() => driftDatabase(name: 'kosply_mobile');

  @override
  int get schemaVersion => 1;
}
