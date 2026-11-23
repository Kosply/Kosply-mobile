/// @title Notification watch
/// @notice Polls the signed-in inbox and posts new rows to the system tray.
/// @dev Started only from [main]. Widget tests never call it, so they do not
/// grow a timer. The first snapshot after each sign-in is silent.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/notifications/notification_repository.dart';
import '../../providers/account/session_provider.dart';
import 'notification_poster.dart';
import 'phone_notifications.dart';

/// @notice Starts polling unread notifications every 10 seconds, and again
/// when the app resumes or the signed-in student changes.
/// @param container The app container created in [main].
/// @return Future completing after the first poll.
Future<void> watchPhoneNotifications(ProviderContainer container) async {
  final NotificationPoster poster = NotificationPoster();
  var signedInAs = '';

  Future<void> poll() async {
    final String userId = container.read(currentUserIdProvider);
    if (userId.isEmpty) {
      return;
    }
    if (userId != signedInAs) {
      poster.reset();
      signedInAs = userId;
    }
    try {
      final items = await container
          .read(notificationRepositoryProvider)
          .list(unreadOnly: true);
      final PhoneNotifications phone = container.read(
        phoneNotificationsProvider,
      );
      for (final item in poster.takeNew(items)) {
        try {
          await phone.show(item);
        } catch (_) {
          // One bad row must not stop the rest of the page.
        }
      }
    } catch (_) {
      // The next tick tries again. A failed poll does not prime the inbox.
    }
  }

  final ProviderSubscription<String> subscription = container.listen<String>(
    currentUserIdProvider,
    (String? _, String _) {
      unawaited(poll());
    },
  );
  final WidgetsBindingObserver observer = _ResumePoller(poll);
  WidgetsBinding.instance.addObserver(observer);
  await poll();
  Timer.periodic(const Duration(seconds: 10), (Timer timer) {
    if (!subscription.closed) {
      unawaited(poll());
    }
  });
}

/// @title _ResumePoller
/// @notice Polls again when the student comes back to the app.
class _ResumePoller extends WidgetsBindingObserver {
  /// @notice Creates the observer.
  /// @param poll Inbox check.
  _ResumePoller(this._poll);

  final Future<void> Function() _poll;

  /// @notice Polls on resume so a message that arrived in the background
  /// is not stuck behind the 10 second timer.
  /// @param state The new lifecycle state.
  /// @return void
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_poll());
    }
  }
}
