/// @title Phone notifications
/// @notice The system-tray surface the app posts personal notifications to.
/// @dev Widget tests keep the silent implementation. [main] swaps in the
/// Android plugin after the channel exists.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/notifications/app_notification.dart';

/// @title PhoneNotifications
/// @notice Shows one notification on the device.
abstract class PhoneNotifications {
  /// @notice Creates a notification surface.
  const PhoneNotifications();

  /// @notice Asks the system for permission to post notifications.
  /// @return Future completing when the student has answered, or immediately
  /// when the platform has nothing to ask.
  Future<void> requestPermission();

  /// @notice Posts [item] on a high-importance channel so it is not silent.
  /// @param item Unread row from the server. Every type is shown.
  /// @return Future completing when the system has accepted it.
  Future<void> show(AppNotification item);
}

/// @title SilentPhoneNotifications
/// @notice Notification surface that keeps the tray empty.
class SilentPhoneNotifications extends PhoneNotifications {
  /// @notice Creates the silent surface.
  const SilentPhoneNotifications();

  /// @notice Does nothing.
  /// @return A completed future.
  @override
  Future<void> requestPermission() async {}

  /// @notice Does nothing.
  /// @param item Ignored.
  /// @return A completed future.
  @override
  Future<void> show(AppNotification item) async {}
}

/// @notice Title shown in the tray. A blank server title becomes "Kosply".
/// @param title Server title.
/// @return The tray title.
String notificationTitle(String title) {
  final String trimmed = title.trim();
  return trimmed.isEmpty ? 'Kosply' : trimmed;
}

/// @dev Silent until [main] overrides it with the prepared plugin.
final phoneNotificationsProvider = Provider<PhoneNotifications>(
  (ref) => const SilentPhoneNotifications(),
);
