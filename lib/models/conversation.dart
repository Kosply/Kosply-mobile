/// @title Conversation
/// @notice Inbox thread and a single chat bubble used by the placeholder
/// inbox until a real messaging API is wired up.
/// @author Kosply-mobile
library;

import 'seller.dart';

/// @title Conversation
/// @notice One inbox row: the other student, last preview, and unread state.
class Conversation {
  /// @notice Creates a conversation.
  /// @param id Stable identifier, matching the peer's seller id.
  /// @param peer The other student in the thread.
  /// @param preview Last message shown under the username.
  /// @param timeLabel Clock or relative time shown on the far side.
  /// @param unreadCount Unread messages; a fill is shown when greater than 0.
  /// @param category Inbox chip this thread belongs to, e.g. Penjual.
  /// @return A new {Conversation} instance.
  const Conversation({
    required this.id,
    required this.peer,
    required this.preview,
    required this.timeLabel,
    this.unreadCount = 0,
    this.category = 'Penjual',
  });

  /// @dev Stable identifier, matching the peer's seller id.
  final String id;

  /// @dev The other student in the thread.
  final Seller peer;

  /// @dev Last message shown under the username.
  final String preview;

  /// @dev Clock or relative time shown on the far side.
  final String timeLabel;

  /// @dev Unread messages; a fill is shown when greater than 0.
  final int unreadCount;

  /// @dev Inbox chip this thread belongs to.
  final String category;

  /// @notice Whether the thread has unread messages.
  bool get hasUnread => unreadCount > 0;
}

/// @title ChatMessage
/// @notice One bubble in a chat thread.
class ChatMessage {
  /// @notice Creates a chat message.
  /// @param id Stable identifier of the bubble.
  /// @param text Message body.
  /// @param isMine True when the signed-in student sent it.
  /// @param timeLabel Clock shown with the bubble.
  /// @return A new {ChatMessage} instance.
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.timeLabel,
  });

  /// @dev Stable identifier of the bubble.
  final String id;

  /// @dev Message body.
  final String text;

  /// @dev True when the signed-in student sent it.
  final bool isMine;

  /// @dev Clock shown with the bubble.
  final String timeLabel;
}
