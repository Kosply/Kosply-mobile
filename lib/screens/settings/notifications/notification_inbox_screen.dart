/// @title Notification inbox
/// @notice Lists `GET /api/notifications` and marks rows read.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/notifications/notification_repository.dart';
import '../../../models/notifications/app_notification.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/empty/empty_state_card.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';

/// @dev The latest page. Invalidated after a read.
final notificationInboxProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) {
      return ref.watch(notificationRepositoryProvider).list();
    });

/// @title NotificationInboxScreen
/// @notice Personal notification list.
class NotificationInboxScreen extends ConsumerWidget {
  /// @notice Creates the inbox.
  /// @return A new {NotificationInboxScreen} instance.
  const NotificationInboxScreen({super.key});

  /// @dev Named route.
  static const routeName = '/notifications';

  /// @notice Pushes this screen.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const NotificationInboxScreen(),
      ),
    );
  }

  Future<void> _markAll(WidgetRef ref, BuildContext context) async {
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      ref.invalidate(notificationInboxProvider);
    } on ApiException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
    }
  }

  Future<void> _open(WidgetRef ref, AppNotification item) async {
    if (item.isRead) {
      return;
    }
    try {
      await ref.read(notificationRepositoryProvider).markRead(item.id);
      ref.invalidate(notificationInboxProvider);
    } on ApiException {
      return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<AppNotification>> page = ref.watch(
      notificationInboxProvider,
    );
    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        title: const Text('Notifikasi'),
        actions: [
          TextButton(
            key: const Key('notifications-read-all'),
            onPressed: () => _markAll(ref, context),
            child: const Text('Baca semua'),
          ),
        ],
      ),
      body: page.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(
          child: Text(
            error is ApiException
                ? error.userMessage
                : 'Notifikasi belum bisa dimuat.',
          ),
        ),
        data: (List<AppNotification> items) {
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: EmptyStateCard(
                icon: PhosphorCode.bell,
                message: 'Belum ada notifikasi.',
              ),
            );
          }
          return ListView.separated(
            key: const Key('notification-list'),
            itemCount: items.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final AppNotification item = items[index];
              return ListTile(
                key: Key('notification-${item.id}'),
                title: Text(item.title),
                subtitle: Text(item.body),
                trailing: item.isRead
                    ? null
                    : const Icon(
                        Icons.circle,
                        size: 8,
                        color: KosplyColors.primary,
                      ),
                onTap: () => _open(ref, item),
              );
            },
          );
        },
      ),
    );
  }
}
