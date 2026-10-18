/// @title PlaceholderInbox
/// @notice Stand-in conversations and chat threads until messaging is wired.
/// @dev Also builds the seed rows the offline-first cache is filled with on
/// first launch.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../models/catalog/seller.dart';
import '../../models/chat/conversation.dart';
import '../shared/local_user.dart';

/// @title PlaceholderInbox
/// @notice Fake data source for the Inbox tab and chat detail.
class PlaceholderInbox {
  // @dev Prevents instantiation of this utility holder.
  const PlaceholderInbox._();

  /// @notice Inbox threads, newest activity first.
  /// @return The placeholder conversation list.
  static List<Conversation> conversations() {
    return <Conversation>[
      Conversation(
        id: 'seller-1',
        peer: Seller.placeholder(0),
        preview: 'Meja masih available?',
        timeLabel: '10:24',
        unreadCount: 2,
        category: 'Penjual',
      ),
      Conversation(
        id: 'seller-2',
        peer: Seller.placeholder(1),
        preview: 'Bisa COD di Ganesha?',
        timeLabel: 'Kemarin',
        category: 'Pembeli',
      ),
      Conversation(
        id: 'seller-3',
        peer: Seller.placeholder(2),
        preview: 'Oke, saya hold dulu ya',
        timeLabel: 'Sen',
        unreadCount: 1,
        category: 'Penjual',
      ),
      Conversation(
        id: 'seller-4',
        peer: Seller.placeholder(3),
        preview: 'Harga bisa kurang?',
        timeLabel: '12 Agu',
        category: 'Pembeli',
      ),
    ];
  }

  /// @notice Builds the conversation rows seeded into the local cache.
  /// @dev Thread ids keep the peer seller id so chat detail can be opened
  /// straight from an inbox row.
  /// @param now UTC millis used as the reference time.
  /// @return Conversation companions, newest activity first.
  static List<ConversationsCompanion> conversationRows({required int now}) {
    return <ConversationsCompanion>[
      for (int i = 0; i < _lastMessageOffsets.length; i++)
        ConversationsCompanion.insert(
          id: 'seller-${i + 1}',
          productId: Value<String>('product-$i'),
          buyerId: const Value<String>(localUserId),
          sellerId: Value<String>('seller-${i + 1}'),
          lastMessageAt: Value<int>(_lastMessageMillis(now: now, index: i)),
          createdAt: Value<int>(_lastMessageMillis(now: now, index: i)),
          backendUpdatedAt: Value<int>(_lastMessageMillis(now: now, index: i)),
          updatedAt: Value<int>(now),
          lastFetched: Value<int>(now),
        ),
    ];
  }

  /// @notice Builds the bubbles seeded into the local cache.
  /// @dev The last bubble repeats the inbox preview so the derived preview and
  /// the seeded conversation always agree. Threads 1 and 3 end with an unread
  /// peer bubble, matching the unread dots in the placeholder copy.
  /// @param now UTC millis used as the reference time.
  /// @return Message companions, oldest first.
  static List<MessagesCompanion> messageRows({required int now}) {
    final List<MessagesCompanion> rows = <MessagesCompanion>[];
    final List<Conversation> items = conversations();
    for (int i = 0; i < items.length; i++) {
      final Conversation item = items[i];
      final DateTime last = DateTime.fromMillisecondsSinceEpoch(
        _lastMessageMillis(now: now, index: i),
      );
      final bool endsUnread = i == 0 || i == 2;
      rows.addAll(<MessagesCompanion>[
        MessagesCompanion.insert(
          id: '${item.id}-m0',
          conversationId: item.id,
          senderId: const Value<String>(localUserId),
          body: Value<String>('Hai ${item.peer.name}, barangnya masih ada?'),
          isRead: const Value<bool>(true),
          createdAt: Value<int>(
            last.subtract(const Duration(minutes: 4)).millisecondsSinceEpoch,
          ),
        ),
        MessagesCompanion.insert(
          id: '${item.id}-m1',
          conversationId: item.id,
          senderId: Value<String>(item.peer.id),
          body: const Value<String>('Masih ada. Mau pickup kapan?'),
          isRead: const Value<bool>(true),
          createdAt: Value<int>(
            last.subtract(const Duration(minutes: 2)).millisecondsSinceEpoch,
          ),
        ),
        MessagesCompanion.insert(
          id: '${item.id}-m2',
          conversationId: item.id,
          senderId: Value<String>(item.peer.id),
          body: Value<String>(item.preview),
          isRead: Value<bool>(!endsUnread),
          readAt: Value<int>(endsUnread ? 0 : last.millisecondsSinceEpoch),
          createdAt: Value<int>(last.millisecondsSinceEpoch),
        ),
      ]);
    }
    return rows;
  }

  /// @dev Activity offsets of the placeholder threads.
  static const List<Duration> _lastMessageOffsets = <Duration>[
    Duration.zero,
    Duration(days: 1),
    Duration(days: 5),
    Duration(days: 30),
  ];

  /// @notice Reference time of one placeholder thread.
  /// @dev The first thread stays at 10:24 today so the inbox shows a stable
  /// clock label, mirroring the placeholder copy.
  /// @param now UTC millis used as the reference time.
  /// @param index Zero-based thread slot.
  /// @return UTC millis of the thread's last bubble.
  static int _lastMessageMillis({required int now, required int index}) {
    if (index == 0) {
      final DateTime local = DateTime.fromMillisecondsSinceEpoch(now);
      return DateTime(
        local.year,
        local.month,
        local.day,
        10,
        24,
      ).millisecondsSinceEpoch;
    }
    return now - _lastMessageOffsets[index].inMilliseconds;
  }

  /// @notice Looks a conversation up by id.
  /// @dev Falls back to the first thread so a bad id still renders a screen.
  /// @param id Identifier taken from [Conversation.id].
  /// @return The matching conversation, or a fallback.
  static Conversation byId(String id) {
    final List<Conversation> items = conversations();
    for (final Conversation item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return items.first;
  }

  /// @notice Placeholder bubbles for one thread.
  /// @param conversationId Identifier taken from [Conversation.id].
  /// @return Messages oldest-first.
  static List<ChatMessage> messagesFor(String conversationId) {
    final Conversation conversation = byId(conversationId);
    final String name = conversation.peer.name;
    return <ChatMessage>[
      ChatMessage(
        id: '$conversationId-m0',
        text: 'Hai $name, barangnya masih ada?',
        isMine: true,
        timeLabel: '09:12',
      ),
      ChatMessage(
        id: '$conversationId-m1',
        text: 'Masih ada. Mau pickup kapan?',
        isMine: false,
        timeLabel: '09:18',
      ),
      ChatMessage(
        id: '$conversationId-m2',
        text: conversation.preview,
        isMine: conversation.hasUnread,
        timeLabel: conversation.timeLabel,
      ),
    ];
  }
}
