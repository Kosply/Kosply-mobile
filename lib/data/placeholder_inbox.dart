/// @title PlaceholderInbox
/// @notice Stand-in conversations and chat threads until messaging is wired.
/// @author Kosply-mobile
library;

import '../models/conversation.dart';
import '../models/seller.dart';

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
