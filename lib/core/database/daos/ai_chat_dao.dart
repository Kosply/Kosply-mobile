/// @title AI chat DAO
/// @notice Local reads and writes for Home AI conversations and bubbles.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/ai_tables.dart';

part 'ai_chat_dao.g.dart';

/// @title AiChatDao
/// @notice Reactive access to the persisted AI history.
@DriftAccessor(tables: [AiConversations, AiMessages])
class AiChatDao extends DatabaseAccessor<AppDatabase> with _$AiChatDaoMixin {
  /// @notice Creates the DAO.
  /// @param db Owning database.
  /// @return A new {AiChatDao} instance.
  AiChatDao(super.db);

  /// @notice Streams every conversation, newest activity first.
  /// @return Stream of conversation rows.
  Stream<List<AiConversationRow>> watchConversations() {
    return (select(aiConversations)
          ..orderBy(<OrderingTerm Function($AiConversationsTable)>[
            ($AiConversationsTable row) =>
                OrderingTerm.desc(row.lastMessageAt),
          ]))
        .watch();
  }

  /// @notice Streams every cached bubble, oldest first.
  /// @dev Used together with the conversation watch to rebuild the history
  /// list with previews in one pass.
  /// @return Stream of bubble rows.
  Stream<List<AiMessageRow>> watchAllMessages() {
    return (select(aiMessages)
          ..orderBy(<OrderingTerm Function($AiMessagesTable)>[
            ($AiMessagesTable row) => OrderingTerm.asc(row.createdAt),
          ]))
        .watch();
  }

  /// @notice Reads every conversation once, newest activity first.
  /// @dev One-shot twin of {watchConversations}; skips stream bookkeeping.
  /// @return The conversation rows as currently cached.
  Future<List<AiConversationRow>> conversationsOnce() {
    return (select(aiConversations)
          ..orderBy(<OrderingTerm Function($AiConversationsTable)>[
            ($AiConversationsTable row) =>
                OrderingTerm.desc(row.lastMessageAt),
          ]))
        .get();
  }

  /// @notice Reads every cached bubble once, oldest first.
  /// @dev One-shot twin of {watchAllMessages}.
  /// @return The bubble rows as currently cached.
  Future<List<AiMessageRow>> allMessagesOnce() {
    return (select(aiMessages)
          ..orderBy(<OrderingTerm Function($AiMessagesTable)>[
            ($AiMessagesTable row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
  }

  /// @notice Streams the bubbles of one conversation.
  /// @param conversationId Identifier taken from {AiConversationRow.id}.
  /// @return Stream of bubble rows, oldest first.
  Stream<List<AiMessageRow>> watchMessages(String conversationId) {
    return (select(aiMessages)
          ..where(
            ($AiMessagesTable row) => row.conversationId.equals(conversationId),
          )
          ..orderBy(<OrderingTerm Function($AiMessagesTable)>[
            ($AiMessagesTable row) => OrderingTerm.asc(row.createdAt),
          ]))
        .watch();
  }

  /// @notice Whether the AI history has never been filled.
  /// @return Future resolving to true when no conversation is cached.
  Future<bool> isConversationCacheEmpty() async {
    final Expression<int> count = aiConversations.id.count();
    final TypedResult row =
        await (selectOnly(aiConversations)..addColumns([count])).getSingle();
    return (row.read(count) ?? 0) == 0;
  }

  /// @notice Inserts or updates one conversation.
  /// @param row Conversation companion to store.
  /// @return Future completing when the write is durable.
  Future<void> upsertConversation(AiConversationsCompanion row) {
    return into(aiConversations).insertOnConflictUpdate(row);
  }

  /// @notice Upserts bubbles without dropping what is already cached.
  /// @param rows Bubble companions to store.
  /// @return Future completing when the transaction is durable.
  Future<void> upsertMessages(List<AiMessagesCompanion> rows) {
    return transaction(() async {
      await batch((Batch batch) {
        batch.insertAll(aiMessages, rows, mode: InsertMode.insertOrReplace);
      });
    });
  }

  /// @notice Replaces the conversation list atomically.
  /// @dev Wraps the delete and the bulk insert in one transaction so a failed
  /// refresh never leaves a half-written history behind.
  /// @param rows Conversation companions to store.
  /// @param fetchedAt UTC millis of this refresh.
  /// @return Future completing when the transaction is durable.
  Future<void> replaceConversations({
    required List<AiConversationsCompanion> rows,
    required int fetchedAt,
  }) {
    return transaction(() async {
      await delete(aiConversations).go();
      await batch((Batch batch) {
        batch.insertAll(aiConversations, rows);
      });
    });
  }

  /// @notice Replaces the bubbles of one conversation atomically.
  /// @param conversationId Identifier taken from {AiConversationRow.id}.
  /// @param rows Bubble companions to store.
  /// @param fetchedAt UTC millis of this refresh.
  /// @return Future completing when the transaction is durable.
  Future<void> replaceMessages({
    required String conversationId,
    required List<AiMessagesCompanion> rows,
    required int fetchedAt,
  }) {
    return transaction(() async {
      await (delete(aiMessages)
            ..where(
              ($AiMessagesTable row) =>
                  row.conversationId.equals(conversationId),
            ))
          .go();
      await batch((Batch batch) {
        batch.insertAll(aiMessages, rows);
      });
    });
  }
}
