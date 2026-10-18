/// @title SupportTicket
/// @notice Contact-support thread listed like an inbox row.
/// @author Kosply-mobile
library;

/// @title SupportTicket
/// @notice One student ticket with Kosply support.
class SupportTicket {
  /// @notice Creates a support ticket.
  /// @param id Stable identifier used to route to the ticket screen.
  /// @param title Subject shown as the inbox-style username line.
  /// @param preview Last message shown under the title.
  /// @param timeLabel Clock or relative time on the far side.
  /// @param status Open or Close, used by the category chips.
  /// @param topicTitle Help-desk problem this ticket is about.
  /// @param unreadCount Unread replies; a fill is shown when greater than 0.
  /// @return A new {SupportTicket} instance.
  const SupportTicket({
    required this.id,
    required this.title,
    required this.preview,
    required this.timeLabel,
    required this.status,
    required this.topicTitle,
    this.unreadCount = 0,
  });

  /// @dev Stable identifier used to route to the ticket screen.
  final String id;

  /// @dev Subject shown as the inbox-style username line.
  final String title;

  /// @dev Last message shown under the title.
  final String preview;

  /// @dev Clock or relative time on the far side.
  final String timeLabel;

  /// @dev Open or Close.
  final String status;

  /// @dev Help-desk problem this ticket is about.
  final String topicTitle;

  /// @dev Unread replies; a fill is shown when greater than 0.
  final int unreadCount;

  /// @notice Whether the ticket has unread replies.
  bool get hasUnread => unreadCount > 0;

  /// @dev Chip and ticket status for an open thread.
  static const String statusOpen = 'Open';

  /// @dev Chip and ticket status for a closed thread.
  static const String statusClose = 'Close';
}
