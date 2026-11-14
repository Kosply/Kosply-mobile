/// @title InboxRepository
/// @notice Offline-first COD chat: rooms, members, and bubbles.
/// @dev Reads stream from Drift; refreshes and sends go through
/// `/api/conversations` (`postman/specs/tables/conversations.md`). Every room
/// is keyed by its backend id; [currentUserId] decides which member is "the
/// other side" and which bubbles are mine.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../../core/database/daos/inbox_dao.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/cache_marker.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/json_read.dart';
import '../../core/network/sse.dart';
import '../../models/catalog/seller.dart';
import '../../models/chat/conversation.dart';
import '../shared/stream_utils.dart';
import '../shared/time_labels.dart';

/// @title InboxRepository
/// @notice Chat access for the inbox and the chat detail screen.
class InboxRepository {
  /// @notice Creates the repository.
  /// @param dao Drift access to the inbox cache.
  /// @param api Backend client.
  /// @param currentUserId Backend id of the signed-in student.
  /// @return A new {InboxRepository} instance.
  InboxRepository({
    required this.dao,
    required this.api,
    required this.currentUserId,
  });

  /// @dev Drift access to the inbox cache.
  final InboxDao dao;

  /// @dev Backend client.
  final ApiClient api;

  /// @dev Backend id of the signed-in student.
  final String currentUserId;

  /// @notice Replaces the cached inbox with `GET /api/conversations`.
  /// @return Future completing when the cache matches the server.
  Future<void> refresh() async {
    final Map<String, dynamic> json = await api.get('/api/conversations');
    final List<Map<String, dynamic>> rooms = json.objects('items');
    final int now = utcMillisNow();
    await dao.replaceConversations(
      rows: <ConversationsCompanion>[
        for (final Map<String, dynamic> room in rooms) _roomRow(room, now),
      ],
      fetchedAt: now,
    );
    await dao.upsertRooms(
      members: <UsersCompanion>[
        for (final Map<String, dynamic> room in rooms) ..._memberRows(room, now),
      ],
      bubbles: <MessagesCompanion>[
        for (final Map<String, dynamic> room in rooms)
          if (room.object('lastMessage') != null)
            _messageRow(room.object('lastMessage')!, now),
      ],
    );
  }

  /// @notice Opens (or reuses) the room about one product.
  /// @dev The server derives the seller from the product, and returns the
  /// existing room when this buyer already asked about it.
  /// @param productId Product being negotiated.
  /// @return The room id.
  Future<String> openForProduct(String productId) {
    return _open(<String, Object?>{'productId': productId});
  }

  /// @notice Opens a room with a seller directly, without a product.
  /// @param sellerId Backend id of an approved seller.
  /// @return The room id.
  Future<String> openForSeller(String sellerId) {
    return _open(<String, Object?>{'sellerId': sellerId});
  }

  /// @notice Pulls one room (members and thread) into the cache.
  /// @dev `GET /api/conversations/:id` also lets the chat screen title itself
  /// when it was opened from a product, before the inbox ever loaded.
  /// @param conversationId Room id.
  /// @return Future completing when the cache holds the room.
  Future<void> refreshRoom(String conversationId) async {
    final Map<String, dynamic> json = await api.get(
      '/api/conversations/$conversationId',
    );
    await _storeRoom(json.object('item') ?? const <String, dynamic>{});
    await refreshMessages(conversationId);
  }

  /// @notice Pulls the thread; the server marks the other side's bubbles read.
  /// @param conversationId Room id.
  /// @return Future completing when the thread is cached.
  Future<void> refreshMessages(String conversationId) async {
    final Map<String, dynamic> json = await api.get(
      '/api/conversations/$conversationId/messages',
    );
    final int now = utcMillisNow();
    await dao.replaceMessages(
      conversationId: conversationId,
      rows: <MessagesCompanion>[
        for (final Map<String, dynamic> item in json.objects('items'))
          _messageRow(item, now),
      ],
      fetchedAt: now,
    );
    await dao.clearUnread(conversationId);
  }

  /// @notice Reads one SSE session and upserts any messages it carries.
  /// @dev The server ends the stream after about 55 seconds. The chat screen
  /// opens the next one. `GET /api/conversations/:id/stream`.
  /// @param conversationId Room id.
  /// @return Future completing when the stream ends.
  Future<void> pullStream(String conversationId) async {
    final List<MessagesCompanion> rows = <MessagesCompanion>[];
    final int now = utcMillisNow();
    await for (final SseEvent event in api.openSse(
      'GET',
      '/api/conversations/$conversationId/stream',
      timeout: const Duration(seconds: 70),
    )) {
      if (event.name == 'message') {
        final Map<String, dynamic> item = Map<String, dynamic>.of(event.json);
        if (item.str('conversationId').isEmpty) {
          item['conversationId'] = conversationId;
        }
        rows.add(_messageRow(item, now));
      } else if (event.name == 'error') {
        throw ApiException(
          statusCode: 502,
          code: 'STREAM_INTERRUPTED',
          message: event.json.str('message'),
        );
      } else if (event.name == 'done') {
        break;
      }
    }
    if (rows.isNotEmpty) {
      await dao.upsertMessages(rows);
      await dao.clearUnread(conversationId);
    }
  }

  /// @notice Long-polls for replies when the stream cannot be opened.
  /// @dev `GET /api/conversations/:id/wait`. An empty wait is a normal timeout.
  /// @param conversationId Room id.
  /// @param after Message id to read after. Empty reads whatever is new.
  /// @return True when at least one new message arrived.
  Future<bool> waitForMessages(String conversationId, {String? after}) async {
    final Map<String, dynamic> json = await api.get(
      '/api/conversations/$conversationId/wait',
      query: <String, String>{
        'timeout': '20',
        if (after != null && after.isNotEmpty) 'after': after,
      },
      timeout: const Duration(seconds: 30),
    );
    final int now = utcMillisNow();
    final List<MessagesCompanion> rows = <MessagesCompanion>[
      for (final Map<String, dynamic> item in json.objects('messages'))
        _messageRow(
          item.str('conversationId').isEmpty
              ? (Map<String, dynamic>.of(item)..['conversationId'] = conversationId)
              : item,
          now,
        ),
    ];
    if (rows.isEmpty) {
      return false;
    }
    await dao.upsertMessages(rows);
    await dao.clearUnread(conversationId);
    return true;
  }

  /// @notice Sends a text bubble.
  /// @param conversationId Room id.
  /// @param text Message text.
  /// @return Future completing when the server stored it and the cache shows it.
  Future<void> sendText(String conversationId, String text) async {
    final Map<String, dynamic> json = await api.post(
      '/api/conversations/$conversationId/messages',
      body: <String, String>{'type': 'TEXT', 'text': text},
    );
    final Map<String, dynamic> item =
        json.object('item') ?? const <String, dynamic>{};
    final int now = utcMillisNow();
    await dao.upsertRooms(
      rooms: <ConversationsCompanion>[
        ConversationsCompanion(
          id: Value<String>(conversationId),
          lastMessageAt: Value<int>(item.millis('createdAt')),
          updatedAt: Value<int>(now),
        ),
      ],
      bubbles: <MessagesCompanion>[_messageRow(item, now)],
    );
  }

  /// @notice Streams the inbox, newest activity first.
  /// @return Stream of conversations whose other member is cached.
  Stream<List<Conversation>> watchConversations() {
    return combineLatest2(
      dao.watchConversationsWithPeers(),
      dao.watchAllMessages(),
      (List<ConversationWithPeers> threads, List<MessageRow> messages) {
        return <Conversation>[
          for (final ConversationWithPeers thread in threads)
            if (_peerOf(thread) != null) _toConversation(thread, messages),
        ];
      },
    );
  }

  /// @notice Streams the other member of one room.
  /// @param conversationId Room id.
  /// @return Stream of the peer, or null while the room is not cached.
  Stream<Seller?> watchPeer(String conversationId) {
    return dao.watchConversationsWithPeers().map((
      List<ConversationWithPeers> threads,
    ) {
      for (final ConversationWithPeers thread in threads) {
        if (thread.$1.id == conversationId) {
          return _peerOf(thread);
        }
      }
      return null;
    });
  }

  /// @notice Streams one room's bubbles, oldest first.
  /// @param conversationId Room id.
  /// @return Stream of messages.
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return dao.watchMessages(conversationId).map(_toMessages);
  }

  Future<String> _open(Map<String, Object?> body) async {
    final Map<String, dynamic> json = await api.post(
      '/api/conversations',
      body: body,
    );
    final Map<String, dynamic> room =
        json.object('item') ?? const <String, dynamic>{};
    await _storeRoom(room);
    return room.str('id');
  }

  Future<void> _storeRoom(Map<String, dynamic> room) async {
    if (room.str('id').isEmpty) {
      return;
    }
    final int now = utcMillisNow();
    await dao.upsertRooms(
      rooms: <ConversationsCompanion>[_roomRow(room, now, withUnread: false)],
      members: _memberRows(room, now),
      bubbles: <MessagesCompanion>[
        for (final Map<String, dynamic> item in room.objects('messages'))
          _messageRow(item, now),
      ],
    );
  }

  ConversationsCompanion _roomRow(
    Map<String, dynamic> room,
    int now, {
    bool withUnread = true,
  }) {
    final Map<String, dynamic>? product = room.object('product');
    return ConversationsCompanion(
      id: Value<String>(room.str('id')),
      productId: Value<String>(product?.str('id') ?? room.str('productId')),
      buyerId: Value<String>(room.str('buyerId')),
      sellerId: Value<String>(room.str('sellerId')),
      agreedLatitude: Value<double>(room.real('agreedLatitude')),
      agreedLongitude: Value<double>(room.real('agreedLongitude')),
      agreedLocationLabel: Value<String>(room.str('agreedLocationLabel')),
      lastMessageAt: Value<int>(
        room.millis('lastMessageAt') == 0
            ? room.millis('createdAt')
            : room.millis('lastMessageAt'),
      ),
      createdAt: Value<int>(room.millis('createdAt')),
      backendUpdatedAt: Value<int>(room.millis('updatedAt')),
      unreadCount: withUnread
          ? Value<int>(room.integer('unreadCount'))
          : const Value<int>.absent(),
      updatedAt: Value<int>(now),
      lastFetched: Value<int>(now),
    );
  }

  List<UsersCompanion> _memberRows(Map<String, dynamic> room, int now) {
    return <UsersCompanion>[
      for (final String key in <String>['buyer', 'seller'])
        if (room.object(key) != null && room.object(key)!.str('id').isNotEmpty)
          UsersCompanion(
            id: Value<String>(room.object(key)!.str('id')),
            username: Value<String>(room.object(key)!.str('username')),
            name: Value<String>(room.object(key)!.str('name')),
            photo: Value<String>(room.object(key)!.str('photo')),
            universitas: Value<String>(room.object(key)!.str('universitas')),
            role: Value<String>(room.object(key)!.str('role')),
            updatedAt: Value<int>(now),
            lastFetched: Value<int>(now),
          ),
    ];
  }

  MessagesCompanion _messageRow(Map<String, dynamic> item, int now) {
    return MessagesCompanion(
      id: Value<String>(item.str('id')),
      conversationId: Value<String>(item.str('conversationId')),
      senderId: Value<String>(item.str('senderId')),
      type: Value<String>(item.str('type').isEmpty ? 'TEXT' : item.str('type')),
      body: Value<String>(item.str('text')),
      imageUrl: Value<String>(item.str('imageUrl')),
      latitude: Value<double>(item.real('latitude')),
      longitude: Value<double>(item.real('longitude')),
      locationLabel: Value<String>(item.str('locationLabel')),
      isRead: Value<bool>(item.flag('isRead')),
      readAt: Value<int>(item.millis('readAt')),
      createdAt: Value<int>(item.millis('createdAt')),
      updatedAt: Value<int>(now),
      lastFetched: Value<int>(now),
    );
  }

  List<ChatMessage> _toMessages(List<MessageRow> rows) {
    return <ChatMessage>[
      for (final MessageRow row in rows)
        ChatMessage(
          id: row.id,
          text: row.body,
          isMine: row.senderId == currentUserId,
          timeLabel: timeLabelFor(row.createdAt),
        ),
    ];
  }

  Conversation _toConversation(
    ConversationWithPeers thread,
    List<MessageRow> messages,
  ) {
    final ConversationRow row = thread.$1;
    final Seller peer = _peerOf(thread)!;
    MessageRow? last;
    for (final MessageRow item in messages) {
      if (item.conversationId == row.id) {
        last = item;
      }
    }
    return Conversation(
      id: row.id,
      peer: peer,
      preview: last?.body ?? '',
      timeLabel: timeLabelFor(row.lastMessageAt),
      unreadCount: row.unreadCount,
      category: row.sellerId == currentUserId ? 'Pembeli' : 'Penjual',
    );
  }

  Seller? _peerOf(ConversationWithPeers thread) {
    final ConversationRow row = thread.$1;
    final UserRow? peer = row.sellerId == currentUserId ? thread.$2 : thread.$3;
    if (peer == null) {
      return null;
    }
    return Seller(
      id: peer.id,
      name: peer.name,
      avatarPath: peer.photo,
      activeLabel: peer.backendUpdatedAt == 0
          ? ''
          : activityLabelFor(peer.backendUpdatedAt),
      bio: peer.bio,
    );
  }
}
