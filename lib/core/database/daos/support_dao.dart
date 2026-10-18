/// @title Support DAO
/// @notice Local reads and writes for help topics and support tickets.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/support_tables.dart';

part 'support_dao.g.dart';

/// @title SupportDao
/// @notice Reactive access to the cached help centre.
@DriftAccessor(tables: [HelpTopics, SupportTickets, SupportMessages])
class SupportDao extends DatabaseAccessor<AppDatabase> with _$SupportDaoMixin {
  /// @notice Creates the DAO.
  /// @param db Owning database.
  /// @return A new {SupportDao} instance.
  SupportDao(super.db);

  /// @notice Streams the FAQ in display order.
  /// @return Stream of help topic rows.
  Stream<List<HelpTopicRow>> watchHelpTopics() {
    return (select(helpTopics)
          ..orderBy(<OrderingTerm Function($HelpTopicsTable)>[
            ($HelpTopicsTable row) => OrderingTerm.asc(row.sortOrder),
          ]))
        .watch();
  }

  /// @notice Whether the FAQ cache has never been filled.
  /// @return Future resolving to true when nothing is cached.
  Future<bool> isHelpTopicCacheEmpty() async {
    final Expression<int> count = helpTopics.id.count();
    final TypedResult row =
        await (selectOnly(helpTopics)..addColumns([count])).getSingle();
    return (row.read(count) ?? 0) == 0;
  }

  /// @notice Replaces the FAQ atomically.
  /// @param rows Topic companions to store.
  /// @param fetchedAt UTC millis of this refresh.
  /// @return Future completing when the transaction is durable.
  Future<void> replaceHelpTopics({
    required List<HelpTopicsCompanion> rows,
    required int fetchedAt,
  }) {
    return transaction(() async {
      await delete(helpTopics).go();
      await batch((Batch batch) {
        batch.insertAll(helpTopics, rows);
      });
    });
  }

  /// @notice Streams the ticket list, newest activity first.
  /// @return Stream of ticket rows.
  Stream<List<SupportTicketRow>> watchTickets() {
    return (select(supportTickets)
          ..orderBy(<OrderingTerm Function($SupportTicketsTable)>[
            ($SupportTicketsTable row) =>
                OrderingTerm.desc(row.lastMessageAt),
          ]))
        .watch();
  }

  /// @notice Reads one cached ticket.
  /// @param id Identifier taken from {SupportTicketRow.id}.
  /// @return Future resolving to the row, or null.
  Future<SupportTicketRow?> ticketById(String id) {
    return (select(supportTickets)
          ..where(($SupportTicketsTable row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  /// @notice Whether the ticket cache has never been filled.
  /// @return Future resolving to true when nothing is cached.
  Future<bool> isTicketCacheEmpty() async {
    final Expression<int> count = supportTickets.id.count();
    final TypedResult row =
        await (selectOnly(supportTickets)..addColumns([count])).getSingle();
    return (row.read(count) ?? 0) == 0;
  }

  /// @notice Streams every cached ticket bubble, oldest first.
  /// @dev Used together with the ticket watch to derive previews and unread
  /// counts without a second query per ticket.
  /// @return Stream of message rows.
  Stream<List<SupportMessageRow>> watchAllTicketMessages() {
    return (select(supportMessages)
          ..orderBy(<OrderingTerm Function($SupportMessagesTable)>[
            ($SupportMessagesTable row) => OrderingTerm.asc(row.createdAt),
          ]))
        .watch();
  }

  /// @notice Streams the bubbles of one ticket.
  /// @param ticketId Identifier taken from {SupportTicketRow.id}.
  /// @return Stream of message rows, oldest first.
  Stream<List<SupportMessageRow>> watchTicketMessages(String ticketId) {
    return (select(supportMessages)
          ..where(($SupportMessagesTable row) => row.ticketId.equals(ticketId))
          ..orderBy(<OrderingTerm Function($SupportMessagesTable)>[
            ($SupportMessagesTable row) => OrderingTerm.asc(row.createdAt),
          ]))
        .watch();
  }

  /// @notice Replaces the ticket list atomically.
  /// @param rows Ticket companions to store.
  /// @param fetchedAt UTC millis of this refresh.
  /// @return Future completing when the transaction is durable.
  Future<void> replaceTickets({
    required List<SupportTicketsCompanion> rows,
    required int fetchedAt,
  }) {
    return transaction(() async {
      await delete(supportTickets).go();
      await batch((Batch batch) {
        batch.insertAll(supportTickets, rows);
      });
    });
  }

  /// @notice Replaces the bubbles of one ticket atomically.
  /// @param ticketId Identifier taken from {SupportTicketRow.id}.
  /// @param rows Message companions to store.
  /// @param fetchedAt UTC millis of this refresh.
  /// @return Future completing when the transaction is durable.
  Future<void> replaceTicketMessages({
    required String ticketId,
    required List<SupportMessagesCompanion> rows,
    required int fetchedAt,
  }) {
    return transaction(() async {
      await (delete(supportMessages)
            ..where(($SupportMessagesTable row) => row.ticketId.equals(ticketId)))
          .go();
      await batch((Batch batch) {
        batch.insertAll(supportMessages, rows);
      });
    });
  }
}
