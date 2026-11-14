/// @title Notification repository
/// @notice Inbox plus preference reads for `/api/notifications`.
/// @dev Writes of individual toggles stay in the settings notifier. This
/// type lists, marks read, and loads the server's current flags.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/json_read.dart';
import '../../models/notifications/app_notification.dart';
import '../../providers/network/api_provider.dart';

/// @title NotificationRepository
/// @notice Personal notification inbox.
class NotificationRepository {
  /// @notice Creates the repository.
  /// @param api Backend client.
  /// @return A new {NotificationRepository} instance.
  NotificationRepository({required this.api});

  /// @dev Backend client.
  final ApiClient api;

  /// @notice Lists the caller's notifications, newest first.
  /// @param unreadOnly When true, only unread rows.
  /// @return The page.
  Future<List<AppNotification>> list({bool unreadOnly = false}) async {
    final Map<String, dynamic> json = await api.get(
      '/api/notifications',
      query: <String, String>{if (unreadOnly) 'unreadOnly': 'true'},
    );
    return <AppNotification>[
      for (final Map<String, dynamic> item in json.objects('items'))
        AppNotification.fromJson(item),
    ];
  }

  /// @notice Marks one notification read.
  /// @param id Notification id.
  /// @return Future completing when the server stored it.
  Future<void> markRead(String id) async {
    await api.post('/api/notifications/$id/read');
  }

  /// @notice Marks every notification read.
  /// @return How many rows changed.
  Future<int> markAllRead() async {
    final Map<String, dynamic> json = await api.post(
      '/api/notifications/read-all',
    );
    return json.integer('count');
  }

  /// @notice Reads every preference key.
  /// @return `{key: enabled}`. Missing keys are left out.
  Future<Map<String, bool>> preferences() async {
    final Map<String, dynamic> json = await api.get(
      '/api/notifications/preferences',
    );
    return <String, bool>{
      for (final Map<String, dynamic> item in json.objects('items'))
        item.str('key'): item.flag('enabled'),
    };
  }
}

/// @dev Notification inbox.
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(api: ref.watch(apiClientProvider)),
);
