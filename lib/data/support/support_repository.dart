/// @title SupportRepository
/// @notice Offline-first help centre: FAQ topics and support tickets.
/// @dev Ticket previews and unread counts are derived from the cached bubbles,
/// mirroring the inbox repository.
/// @author Kosply-mobile
library;

import '../../core/database/daos/support_dao.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/cache_marker.dart';
import '../../models/catalog/seller.dart';
import '../../models/chat/conversation.dart';
import '../../models/support/help_topic.dart';
import '../../models/support/support_ticket.dart';
import '../shared/stream_utils.dart';
import '../shared/time_labels.dart';
import 'placeholder_help.dart';

/// @title SupportRepository
/// @notice Reactive access to the cached help centre.
class SupportRepository {
  /// @notice Creates the repository.
  /// @param dao Drift access to the support cache.
  /// @return A new {SupportRepository} instance.
  SupportRepository({required this.dao});

  /// @dev Drift access to the support cache.
  final SupportDao dao;

  /// @notice Streams the FAQ in display order.
  /// @return Stream of help topics.
  Stream<List<HelpTopic>> watchHelpTopics() {
    return dao.watchHelpTopics().map(
      (List<HelpTopicRow> rows) => <HelpTopic>[
        for (final HelpTopicRow row in rows)
          HelpTopic(title: row.title, answer: row.answer),
      ],
    );
  }

  /// @notice Streams the ticket rows, newest activity first.
  /// @return Stream of tickets derived from the cache.
  Stream<List<SupportTicket>> watchTickets() {
    return combineLatest2(
      dao.watchTickets(),
      dao.watchAllTicketMessages(),
      (List<SupportTicketRow> tickets, List<SupportMessageRow> messages) {
        return <SupportTicket>[
          for (final SupportTicketRow ticket in tickets)
            _toTicket(ticket, messages),
        ];
      },
    );
  }

  /// @notice Streams the bubbles of one ticket.
  /// @param ticketId Identifier taken from {SupportTickets.id}.
  /// @return Stream of messages, oldest first.
  Stream<List<ChatMessage>> watchTicketMessages(String ticketId) {
    return dao.watchTicketMessages(ticketId).map(
      (List<SupportMessageRow> rows) => <ChatMessage>[
        for (final SupportMessageRow row in rows)
          ChatMessage(
            id: row.id,
            text: row.body,
            isMine: row.senderRole == 'USER',
            timeLabel: timeLabelFor(row.createdAt),
          ),
      ],
    );
  }

  /// @notice Fills the cache when it has never been synced.
  /// @return Future completing when the cache is ready.
  Future<void> ensureSeeded() async {
    final int now = utcMillisNow();
    if (await dao.isHelpTopicCacheEmpty()) {
      await dao.replaceHelpTopics(
        rows: PlaceholderHelp.topicRows(now: now),
        fetchedAt: now,
      );
    }
    if (await dao.isTicketCacheEmpty()) {
      final List<SupportTicket> tickets = PlaceholderHelp.tickets();
      await dao.replaceTickets(
        rows: PlaceholderHelp.ticketRows(now: now),
        fetchedAt: now,
      );
      final List<SupportMessagesCompanion> messages =
          PlaceholderHelp.ticketMessageRows(now: now);
      for (final SupportTicket ticket in tickets) {
        await dao.replaceTicketMessages(
          ticketId: ticket.id,
          rows: messages
              .where(
                (SupportMessagesCompanion row) =>
                    row.ticketId.value == ticket.id,
              )
              .toList(),
          fetchedAt: now,
        );
      }
    }
  }

  /// @notice The stand-in support agent shown on ticket chat headers.
  /// @return The support {Seller}.
  Seller get agent => PlaceholderHelp.agent;

  SupportTicket _toTicket(
    SupportTicketRow row,
    List<SupportMessageRow> messages,
  ) {
    final List<SupportMessageRow> threadMessages = messages
        .where((SupportMessageRow item) => item.ticketId == row.id)
        .toList();
    final SupportMessageRow? last = threadMessages.isEmpty
        ? null
        : threadMessages.last;
    final int unread = threadMessages
        .where(
          (SupportMessageRow item) => !item.isRead && item.senderRole != 'USER',
        )
        .length;
    return SupportTicket(
      id: row.id,
      title: row.subject,
      preview: last?.body ?? row.description,
      timeLabel: timeLabelFor(row.lastMessageAt),
      status: row.status == 'CLOSED'
          ? SupportTicket.statusClose
          : SupportTicket.statusOpen,
      topicTitle: row.category,
      unreadCount: unread,
    );
  }
}
