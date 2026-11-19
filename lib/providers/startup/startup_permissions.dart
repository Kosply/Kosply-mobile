/// @title Startup permissions
/// @notice Location, then notifications, asked once while the splash is up.
/// @dev Widget tests override this with [DisabledStartupPermissions]. On a
/// desktop host the platform check returns before any plugin call, so the
/// splash timer tests stay quiet too.
/// @author Kosply-mobile
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/location/device_location.dart';
import '../../core/notifications/phone_notifications.dart';
import '../location/location_label_provider.dart';

/// @title StartupPermissions
/// @notice The permission pass that runs at cold start.
abstract class StartupPermissions {
  /// @notice Creates a permission pass.
  const StartupPermissions();

  /// @notice Asks for location, then notification permission.
  /// @return Future completing when both dialogs have been answered, or
  /// immediately when there is nothing to ask.
  Future<void> ask();
}

/// @title DisabledStartupPermissions
/// @notice Permission pass that never opens a dialog.
class DisabledStartupPermissions extends StartupPermissions {
  /// @notice Creates the disabled pass.
  const DisabledStartupPermissions();

  /// @notice Does nothing.
  /// @return A completed future.
  @override
  Future<void> ask() async {}
}

/// @title PlatformStartupPermissions
/// @notice Android permission dialogs, location first.
class PlatformStartupPermissions extends StartupPermissions {
  /// @notice Creates the platform pass.
  /// @param location GPS source shared with the home pill.
  /// @param notifications Tray surface that asks for POST_NOTIFICATIONS.
  const PlatformStartupPermissions({
    required this.location,
    required this.notifications,
  });

  /// @dev GPS source. Its permission flag is shared with the home pill.
  final DeviceLocation location;

  /// @dev Tray surface.
  final PhoneNotifications notifications;

  /// @notice Shows the location dialog, then the notification dialog.
  /// @return Future completing when both have been answered.
  @override
  Future<void> ask() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    try {
      await location.ensurePermission();
    } catch (_) {
      // A missing location plugin must not trap the splash.
    }
    try {
      await notifications.requestPermission();
    } catch (_) {
      // A missing notification plugin must not trap the splash.
    }
  }
}

/// @dev Cold-start permission pass.
final startupPermissionsProvider = Provider<StartupPermissions>(
  (ref) => PlatformStartupPermissions(
    location: ref.watch(deviceLocationProvider),
    notifications: ref.watch(phoneNotificationsProvider),
  ),
);
