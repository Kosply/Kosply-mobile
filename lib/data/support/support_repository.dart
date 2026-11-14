/// @title SupportRepository
/// @notice Offline-first Help desk: FAQ topics, tickets, and ticket chat.
/// @dev Reads stream from Drift; refreshes and writes go through
/// `/api/support/*` (`postman/specs/tables/support.md`). The FAQ is public, so
/// it loads before sign-in; tickets are the signed-in student's own.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../../core/database/daos/support_dao.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/cache_marker.dart';
import '../../core/network/api_client.dart';
import '../../core/network/json_read.dart';
import '../../models/catalog/seller.dart';
import '../../models/chat/conversation.dart';
import '../../models/support/help_topic.dart';
import '../../models/support/support_ticket.dart';
import '../shared/stream_utils.dart';
import '../shared/time_labels.dart';

/// @title SupportRepository
/// @notice Help desk access for the support screens.
class SupportRepository {
  /// @notice Creates the repository.
  /// @param dao Drift access to the support cache.
  /// @param api Backend client.
  /// @return A new {SupportRepository} instance.
  SupportRepository({required this.dao, required this.api});

  /// @dev Drift access to the support cache.
  final SupportDao dao;

  /// @dev Backend client.
  final ApiClient api;

  /// @dev Identity shown for staff replies. Staff names stay private, so
  /// every admin bubble reads as the support desk.
  static const Seller supportAgent = Seller(
    id: 'support',
    name: 'Kosply Support',
    avatarPath: Seller.avatar,
    activeLabel: 'aktif sekarang',
    bio: '',
  );

  /// @dev Ticket categories the backend accepts.
  static const List<String> categories = <String>[
    'AKUN',
    'PRODUK',
    'CHAT',
    'VERIFIKASI',
    'LAPORAN',
    'LAINNYA',
  ];

  /// @notice Support identity for ticket rows and ticket chat.
  Seller get agent => supportAgent;

  /// @notice Replaces the cached FAQ with `GET /api/support/help-topics`.
  /// @return Future completing when the cache matches the server.
  Future<void> refreshHelpTopics() async {
    final Map<String, dynamic> json = await api.get(
      '/api/support/help-topics',
      auth: false,
    );
    final int now = utcMillisNow();
    await dao.replaceHelpTopics(
      rows: <HelpTopicsCompanion>[
        for (final Map<String, dynamic> item in json.objects('items'))
          HelpTopicsCompanion(
            id: Value<String>(item.str('id')),
            title: Value<String>(item.str('title')),
            answer: Value<String>(item.str('answer')),
            sortOrder: Value<int>(item.integer('sortOrder')),
            updatedAt: Value<int>(now),
            lastFetched: Value<int>(now),
          ),
      ],
      fetchedAt: now,
    );
  }

  /// @notice Replaces the cached tickets with `GET /api/support/tickets`.
  /// @return Future completing when the cache matches the server.
  Future<void> refreshTickets() async {
    final Map<String, dynamic> json = await api.get('/api/support/tickets');
    final int now = utcMillisNow();
    await dao.replaceTickets(
      rows: <SupportTicketsCompanion>[
        for (final Map<String, dynamic> item in json.objects('items'))
          _ticketRow(item, now),
      ],
      fetchedAt: now,
    );
  }

  /// @notice Pulls one ticket and its thread.
  /// @param ticketId Ticket id.
  /// @return Future completing when the thread is cached.
  Future<void> refreshTicket(String ticketId) async {
    final Map<String, dynamic> json = await api.get(
      '/api/support/tickets/$ticketId',
    );
    final Map<String, dynamic> item =
        json.object('item') ?? const <String, dynamic>{};
    final int now = utcMillisNow();
    await dao.upsertTickets(tickets: <SupportTicketsCompanion>[_ticketRow(item, now)]);
    await dao.replaceTicketMessages(
      ticketId: ticketId,
      rows: <SupportMessagesCompanion>[
        for (final Map<String, dynamic> message in item.objects('messages'))
          _messageRow(message, now),
      ],
      fetchedAt: now,
    );
  }

  /// @notice Opens a ticket from the contact form.
  /// @dev The form picks a FAQ topic; it becomes the subject, and the
  /// category is read from its words so the desk can still filter.
  /// @param topic Chosen FAQ topic title.
  /// @param message Problem description.
  /// @return The new ticket id.
  Future<String> openTicket({
    required String topic,
    required String message,
  }) async {
    final Map<String, dynamic> json = await api.post(
      '/api/support/tickets',
      body: <String, String>{
        'category': categoryFor(topic),
        'subject': topic,
        'description': message,
      },
    );
    final Map<String, dynamic> item = _ticketOf(json);
    final int now = utcMillisNow();
    await dao.upsertTickets(tickets: <SupportTicketsCompanion>[_ticketRow(item, now)]);
    return item.str('id');
  }

  /// @notice Closes a ticket the student owns.
  /// @param ticketId Ticket id.
  /// @return Future completing when the cache shows it closed.
  Future<void> close(String ticketId) async {
    await api.post('/api/support/tickets/$ticketId/close');
    await refreshTicket(ticketId);
  }

  /// @notice Sends a reply on a ticket.
  /// @param ticketId Ticket id.
  /// @param text Reply text.
  /// @return Future completing when the reply is cached.
  Future<void> reply(String ticketId, String text) async {
    final Map<String, dynamic> json = await api.post(
      '/api/support/tickets/$ticketId/messages',
      body: <String, String>{'text': text},
    );
    final Map<String, dynamic> item = _ticketOf(json);
    final int now = utcMillisNow();
    await dao.upsertTickets(
      bubbles: <SupportMessagesCompanion>[_messageRow(item, now)],
    );
  }

  /// @notice Maps a topic title to a backend ticket category.
  /// @param topic FAQ topic title.
  /// @return One of {categories}.
  static String categoryFor(String topic) {
    final String text = topic.toLowerCase();
    if (text.contains('verifik') || text.contains('ktm')) {
      return 'VERIFIKASI';
    }
    if (text.contains('lapor') || text.contains('penipu')) {
      return 'LAPORAN';
    }
    if (text.contains('chat') || text.contains('pesan')) {
      return 'CHAT';
    }
    if (text.contains('akun') ||
        text.contains('login') ||
        text.contains('password')) {
      return 'AKUN';
    }
    if (text.contains('barang') ||
        text.contains('produk') ||
        text.contains('jual')) {
      return 'PRODUK';
    }
    return 'LAINNYA';
  }

  /// @notice Streams the cached FAQ in display order.
  /// @return Stream of topics.
  Stream<List<HelpTopic>> watchHelpTopics() {
    return dao.watchHelpTopics().map(
      (List<HelpTopicRow> rows) => <HelpTopic>[
        for (final HelpTopicRow row in rows)
          HelpTopic(title: row.title, answer: row.answer),
      ],
    );
  }

  /// @notice Streams the cached tickets with their latest bubble.
  /// @return Stream of tickets.
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

  /// @notice Streams one ticket's thread, oldest first.
  /// @param ticketId Ticket id.
  /// @return Stream of messages.
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

  /// @notice Reads the ticket from a create or reply response.
  /// @dev Those routes answer with the row spread into the body rather than
  /// under `item`; accept both shapes.
  /// @param json Response body.
  /// @return The ticket or message object.
  Map<String, dynamic> _ticketOf(Map<String, dynamic> json) {
    return json.object('item') ?? json;
  }

  SupportTicketsCompanion _ticketRow(Map<String, dynamic> item, int now) {
    return SupportTicketsCompanion(
      id: Value<String>(item.str('id')),
      ticketNo: Value<String>(item.str('ticketNo')),
      userId: Value<String>(item.str('userId')),
      category: Value<String>(item.str('category')),
      status: Value<String>(item.str('status')),
      subject: Value<String>(item.str('subject')),
      description: Value<String>(item.str('description')),
      lastMessageAt: Value<int>(
        item.millis('lastMessageAt') == 0
            ? item.millis('createdAt')
            : item.millis('lastMessageAt'),
      ),
      createdAt: Value<int>(item.millis('createdAt')),
      backendUpdatedAt: Value<int>(item.millis('updatedAt')),
      updatedAt: Value<int>(now),
      lastFetched: Value<int>(now),
    );
  }

  SupportMessagesCompanion _messageRow(Map<String, dynamic> item, int now) {
    return SupportMessagesCompanion(
      id: Value<String>(item.str('id')),
      ticketId: Value<String>(item.str('ticketId')),
      senderId: Value<String>(item.str('senderId')),
      senderRole: Value<String>(item.str('senderRole')),
      senderName: Value<String>(item.str('senderName')),
      body: Value<String>(item.str('text')),
      imageUrl: Value<String>(item.str('imageUrl')),
      isInternal: Value<bool>(item.flag('isInternal')),
      isRead: Value<bool>(item.flag('isRead')),
      readAt: Value<int>(item.millis('readAt')),
      createdAt: Value<int>(item.millis('createdAt')),
      updatedAt: Value<int>(now),
      lastFetched: Value<int>(now),
    );
  }

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
      topicTitle: _categoryLabel(row.category),
      unreadCount: unread,
    );
  }

  /// @notice Turns `VERIFIKASI` into `Verifikasi` for the ticket row.
  /// @param category Backend category, or a legacy free-text topic.
  /// @return Display label.
  String _categoryLabel(String category) {
    if (!categories.contains(category)) {
      return category;
    }
    return category[0] + category.substring(1).toLowerCase();
  }
}
