/// @title App notification
/// @notice One row from `GET /api/notifications`.
/// @author Kosply-mobile
library;

import '../../core/network/json_read.dart';

/// @title AppNotification
/// @notice A personal notification the student can mark read.
class AppNotification {
  /// @notice Creates a notification.
  /// @param id Row id.
  /// @param type Server key, e.g. `chat`.
  /// @param title Short title.
  /// @param body Longer text.
  /// @param isRead Whether the student has opened it.
  /// @param createdAt UTC millis.
  /// @return A new {AppNotification} instance.
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  /// @notice Reads one notification row.
  /// @param json Backend object.
  /// @return The notification.
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json.str('id'),
      type: json.str('type'),
      title: json.str('title'),
      body: json.str('body'),
      isRead: json.flag('isRead'),
      createdAt: json.millis('createdAt'),
    );
  }

  /// @dev Row id.
  final String id;

  /// @dev Server key.
  final String type;

  /// @dev Short title.
  final String title;

  /// @dev Longer text.
  final String body;

  /// @dev Whether the student has opened it.
  final bool isRead;

  /// @dev UTC millis.
  final int createdAt;
}
