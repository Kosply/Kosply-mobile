/// @title Notification poster tests
/// @notice The first unread snapshot stays in the inbox, and later rows of
/// every server type are posted.
/// @author Kosply-mobile
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/notifications/notification_poster.dart';
import 'package:kosply_mobile/core/notifications/phone_notifications.dart';
import 'package:kosply_mobile/models/notifications/app_notification.dart';

AppNotification _note(
  String id,
  String type, {
  bool isRead = false,
  String title = 'Judul',
}) {
  return AppNotification(
    id: id,
    type: type,
    title: title,
    body: 'Isi $type',
    isRead: isRead,
    createdAt: 1,
  );
}

void main() {
  test('the first unread snapshot stays quiet and later rows post', () {
    final NotificationPoster poster = NotificationPoster();
    final List<AppNotification> first = poster.takeNew(<AppNotification>[
      _note('chat-1', 'chat'),
      _note('old-read', 'system', isRead: true),
      _note('', 'product'),
    ]);
    expect(first, isEmpty);
    expect(poster.primed, isTrue);

    final List<AppNotification> second = poster.takeNew(<AppNotification>[
      _note('chat-1', 'chat'),
      _note('old-read', 'system', isRead: true),
      _note('verify-1', 'verification'),
      _note('report-1', 'reports'),
      _note('support-1', 'support'),
      _note('product-1', 'product'),
      _note('system-1', 'system', title: '  '),
    ]);

    expect(second.map((AppNotification item) => item.type), <String>[
      'verification',
      'reports',
      'support',
      'product',
      'system',
    ]);
    expect(notificationTitle(second.last.title), 'Kosply');
    expect(notificationTitle('Pesan baru'), 'Pesan baru');
  });

  test('an account switch primes again instead of dumping the new inbox', () {
    final NotificationPoster poster = NotificationPoster();
    poster.takeNew(<AppNotification>[_note('chat-1', 'chat')]);
    poster.reset();

    expect(poster.takeNew(<AppNotification>[_note('chat-2', 'chat')]), isEmpty);
    expect(
      poster.takeNew(<AppNotification>[_note('chat-3', 'support')]).single.id,
      'chat-3',
    );
  });
}
