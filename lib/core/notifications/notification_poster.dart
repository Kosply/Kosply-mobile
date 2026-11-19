/// @title Notification poster
/// @notice Decides which unread rows become a system notification.
/// @dev The first successful snapshot for a student is remembered and not
/// posted, so opening the app does not dump the old inbox. Later unread ids
/// are posted, whatever their server type is.
/// @author Kosply-mobile
library;

import '../../models/notifications/app_notification.dart';

/// @title NotificationPoster
/// @notice Remembers notification ids already seen for the signed-in student.
class NotificationPoster {
  final Set<String> _seen = <String>{};

  /// @dev False until the first snapshot has been recorded.
  bool primed = false;

  /// @notice Forgets the snapshot, for a sign-in or an account switch.
  /// @return void
  void reset() {
    _seen.clear();
    primed = false;
  }

  /// @notice Records [items] and returns the ones that should be posted.
  /// @dev Empty ids are ignored. Read rows are remembered so a later unread
  /// copy of the same id does not pop. The first call only records.
  /// @param items Newest unread page from the server.
  /// @return Rows to show. Empty on the priming snapshot.
  List<AppNotification> takeNew(List<AppNotification> items) {
    final List<AppNotification> fresh = <AppNotification>[];
    for (final AppNotification item in items) {
      if (item.id.isEmpty) {
        continue;
      }
      final bool added = _seen.add(item.id);
      if (!added || item.isRead || !primed) {
        continue;
      }
      fresh.add(item);
    }
    primed = true;
    return fresh;
  }
}
