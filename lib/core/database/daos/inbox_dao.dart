/// @title Inbox DAO
/// @notice Local reads and writes for conversations and chat bubbles.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/account_tables.dart';
import '../tables/inbox_tables.dart';

part 'inbox_dao.g.dart';

/// @notice One cached conversation together with both peer rows.
typedef ConversationWithPeers = (
  ConversationRow conversation,
  UserRow? buyer,
  UserRow? seller,
);

/// @title InboxDao
/// @notice Reactive access to the cached inbox.
@DriftAccessor(tables: [Conversations, Messages, Users])
class InboxDao extends DatabaseAccessor<AppDatabase> with _$InboxDaoMixin {
  /// @notice Creates the DAO.
  /// @param db Owning database.
  /// @return A new {InboxDao} instance.
  InboxDao(super.db);

  /// @notice Streams every cached conversation with both peers attached.
  /// @dev Left join on both sides, so merged threads whose peer row is not in
  /// cache still show up instead of silently disappearing.
  /// @return Stream of conversation/peer triples, newest activity first.
  Stream<List<ConversationWithPeers>> watchConversationsWithPeers() {
    final $UsersTable buyer = alias(users, 'buyer');
    final $UsersTable seller = alias(users, 'seller');
    return (select(conversations).join(<Join<HasResultSet, dynamic>>[
      leftOuterJoin(buyer, buyer.id.equalsExp(conversations.buyerId)),
      leftOuterJoin(seller, seller.id.equalsExp(conversations.sellerId)),
    ])
          ..orderBy(<OrderingTerm>[
            OrderingTerm.desc(conversations.lastMessageAt),
          ]))
        .watch()
        .map(
          (List<TypedResult> rows) => rows
              .map(
                (TypedResult row) => (
                  row.readTable(conversations),
                  row.readTableOrNull(buyer),
                  row.readTableOrNull(seller),
                ),
              )
              .toList(),
        );
  }

  /// @notice Streams every cached conversation, newest activity first.
  /// @return Stream of conversation rows.
  Stream<List<ConversationRow>> watchConversations() {
    return (select(conversations)
          ..orderBy(<OrderingTerm Function($ConversationsTable)>[
            ($ConversationsTable row) =>
                OrderingTerm.desc(row.lastMessageAt),
          ]))
        .watch();
  }

  /// @notice Reads one cached conversation.
  /// @param id Identifier taken from {ConversationRow.id}.
  /// @return Future resolving to the row, or null.
  Future<ConversationRow?> conversationById(String id) {
    return (select(conversations)
          ..where(($ConversationsTable row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  /// @notice Whether the conversation cache has never been filled.
  /// @return Future resolving to true when nothing is cached.
  Future<bool> isConversationCacheEmpty() async {
    final Expression<int> count = conversations.id.count();
    final TypedResult row =
        await (selectOnly(conversations)..addColumns([count])).getSingle();
    return (row.read(count) ?? 0) == 0;
  }

  /// @notice Streams every cached bubble, oldest first.
  /// @dev Used together with the conversation watch to derive previews,
  /// unread counts, and ordering without a second query per thread.
  /// @return Stream of message rows.
  Stream<List<MessageRow>> watchAllMessages() {
    return (select(messages)
          ..orderBy(<OrderingTerm Function($MessagesTable)>[
            ($MessagesTable row) => OrderingTerm.asc(row.createdAt),
          ]))
        .watch();
  }

  /// @notice Streams the bubbles of one thread.
  /// @param conversationId Identifier taken from {ConversationRow.id}.
  /// @return Stream of message rows, oldest first.
  Stream<List<MessageRow>> watchMessages(String conversationId) {
    return (select(messages)
          ..where(($MessagesTable row) => row.conversationId.equals(conversationId))
          ..orderBy(<OrderingTerm Function($MessagesTable)>[
            ($MessagesTable row) => OrderingTerm.asc(row.createdAt),
          ]))
        .watch();
  }

  /// @notice Replaces the conversation list atomically.
  /// @param rows ConversationRow companions to store.
  /// @param fetchedAt UTC millis of this refresh.
  /// @return Future completing when the transaction is durable.
  Future<void> replaceConversations({
    required List<ConversationsCompanion> rows,
    required int fetchedAt,
  }) {
    return transaction(() async {
      await delete(conversations).go();
      await batch((Batch batch) {
        batch.insertAll(conversations, rows);
      });
    });
  }

  /// @notice Replaces the bubbles of one thread atomically.
  /// @param conversationId Identifier taken from {ConversationRow.id}.
  /// @param rows MessageRow companions to store.
  /// @param fetchedAt UTC millis of this refresh.
  /// @return Future completing when the transaction is durable.
  Future<void> replaceMessages({
    required String conversationId,
    required List<MessagesCompanion> rows,
    required int fetchedAt,
  }) {
    return transaction(() async {
      await (delete(messages)
            ..where(
              ($MessagesTable row) => row.conversationId.equals(conversationId),
            ))
          .go();
      await batch((Batch batch) {
        batch.insertAll(messages, rows);
      });
    });
  }

  /// @notice Upserts bubbles without dropping what is already cached.
  /// @param rows MessageRow companions to store.
  /// @return Future completing when the transaction is durable.
  Future<void> upsertMessages(List<MessagesCompanion> rows) {
    return transaction(() async {
      await batch((Batch batch) {
        batch.insertAll(messages, rows, mode: InsertMode.insertOrReplace);
      });
    });
  }
}
