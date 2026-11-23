/// @title Plugin phone notifications
/// @notice Android tray notifications through flutter_local_notifications.
/// @dev The channel is high importance with sound and vibration. ColorOS
/// treats a default channel as silent, which is why the tray looked empty.
/// The small icon is a white glyph; the color mark is the large icon.
/// @author Kosply-mobile
library;

import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../models/notifications/app_notification.dart';
import 'phone_notifications.dart';

/// @dev Channel id. A new id so an older silent channel is not reused.
const String kosplyNotificationChannelId = 'kosply';

/// @title PluginPhoneNotifications
/// @notice Posts every server notification type on the Kosply channel.
class PluginPhoneNotifications extends PhoneNotifications {
  /// @notice Creates the plugin wrapper.
  /// @param plugin Optional plugin, so a test can pass a fake. Production
  /// uses the default constructor.
  PluginPhoneNotifications({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const AndroidNotificationDetails _details = AndroidNotificationDetails(
    kosplyNotificationChannelId,
    'Kosply',
    channelDescription: 'Pesan, dukungan, verifikasi, dan pembaruan',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    silent: false,
    icon: 'ic_stat_notify',
    largeIcon: DrawableResourceAndroidBitmap('splash_logo'),
    color: Color(0xFF4F46E5),
    visibility: NotificationVisibility.public,
  );

  /// @notice Creates the high-importance channel before the first frame.
  /// @dev Failures are swallowed so a desktop run still opens.
  /// @return Future completing when the channel exists, or the attempt ended.
  Future<void> prepare() async {
    try {
      const AndroidInitializationSettings android =
          AndroidInitializationSettings('ic_stat_notify');
      await _plugin.initialize(
        settings: const InitializationSettings(android: android),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              kosplyNotificationChannelId,
              'Kosply',
              description: 'Pesan, dukungan, verifikasi, dan pembaruan',
              importance: Importance.high,
              playSound: true,
              enableVibration: true,
            ),
          );
    } catch (_) {
      // A host without the Android plugin must still reach runApp.
    }
  }

  /// @notice Shows the Android 13 notification permission dialog.
  /// @return Future completing when the student has answered.
  @override
  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// @notice Posts [item] with sound. The type is not filtered.
  /// @param item Unread notification.
  /// @return Future completing when the system has accepted it.
  @override
  Future<void> show(AppNotification item) async {
    await _plugin.show(
      id: _notificationId(item.id),
      title: notificationTitle(item.title),
      body: item.body,
      notificationDetails: const NotificationDetails(android: _details),
    );
  }
}

/// @notice Stable positive id for the Android tray.
/// @param id Server notification id.
/// @return A non-zero 31-bit id.
int _notificationId(String id) {
  var hash = 0;
  for (final int unit in id.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash == 0 ? 1 : hash;
}
