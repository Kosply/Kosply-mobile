/// @title InboxRepository
/// @notice Offline-first conversations: thread rows plus their bubbles.
/// @dev Conversation previews, time labels, and unread counts are derived from
/// the cached messages so the inbox list matches the chat detail exactly.
/// @author Kosply-mobile
library;

import '../../core/database/daos/inbox_dao.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/cache_marker.dart';
import '../../models/catalog/seller.dart';
import '../../models/chat/conversation.dart';
import '../shared/local_user.dart';
import '../shared/stream_utils.dart';
import '../shared/time_labels.dart';
import 'placeholder_inbox.dart';

/// @title InboxRepository
/// @notice Reactive access to the cached inbox.
class InboxRepository {
  /// @notice Creates the repository.
  /// @param dao Drift access to the inbox cache.
  /// @return A new {InboxRepository} instance.
  InboxRepository({required this.dao});

  /// @dev Drift access to the inbox cache.
  final InboxDao dao;

  /// @notice Fills the cache when it has never been synced.
  /// @return Future completing when the cache is ready.
  Future<void> ensureSeeded() async {
    if (await dao.isConversationCacheEmpty()) {
      final int now = utcMillisNow();
      await dao.replaceConversations(
        rows: PlaceholderInbox.conversationRows(now: now),
        fetchedAt: now,
      );
      await dao.upsertMessages(PlaceholderInbox.messageRows(now: now));
    }
  }

  /// @notice Streams the inbox rows, newest activity first.
  /// @dev Threads whose peer row is missing are skipped: chat needs a peer to
  /// open.
  /// @return Stream of conversations derived from the cache.
  Stream<List<Conversation>> watchConversations() {
    return combineLatest2(
      dao.watchConversationsWithPeers(),
      dao.watchAllMessages(),
      (List<ConversationWithPeers> threads, List<MessageRow> messages) {
        return <Conversation>[
          for (final ConversationWithPeers thread in threads)
            if (_peerOf(thread) != null)
              _toConversation(thread, messages),
        ];
      },
    );
  }

  /// @notice Streams the peer of one cached thread.
  /// @param conversationId Identifier taken from {Conversations.id}.
  /// @return Stream of the other student, or null when not cached.
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

  /// @notice Streams the bubbles of one thread.
  /// @param conversationId Identifier taken from {Conversations.id}.
  /// @return Stream of messages, oldest first.
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return dao.watchMessages(conversationId).map(_toMessages);
  }

  List<ChatMessage> _toMessages(List<MessageRow> rows) {
    return <ChatMessage>[
      for (final MessageRow row in rows)
        ChatMessage(
          id: row.id,
          text: row.body,
          isMine: row.senderId == localUserId,
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
    final List<MessageRow> threadMessages = messages
        .where((MessageRow item) => item.conversationId == row.id)
        .toList();
    final MessageRow? last = threadMessages.isEmpty
        ? null
        : threadMessages.last;
    final int unread = threadMessages
        .where(
          (MessageRow item) =>
              !item.isRead &&
              item.senderId.isNotEmpty &&
              item.senderId != localUserId,
        )
        .length;
    return Conversation(
      id: row.id,
      peer: peer,
      preview: last?.body ?? '',
      timeLabel: timeLabelFor(row.lastMessageAt),
      unreadCount: unread,
      category: row.sellerId == localUserId ? 'Pembeli' : 'Penjual',
    );
  }

  Seller? _peerOf(ConversationWithPeers thread) {
    final ConversationRow row = thread.$1;
    final UserRow? buyer = thread.$2;
    final UserRow? seller = thread.$3;
    final UserRow? peer = row.sellerId == localUserId ? buyer : seller;
    if (peer == null) {
      return null;
    }
    return Seller(
      id: peer.id,
      name: peer.name,
      avatarPath: peer.photo,
      activeLabel: activityLabelFor(peer.backendUpdatedAt),
      bio: peer.bio,
    );
  }
}
