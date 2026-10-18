/// @title Placeholder AI chat
/// @notice Stand-in Home AI threads until an assistant API is wired up.
/// @dev Also builds the seed rows the offline-first cache is filled with on
/// first launch.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../models/chat/ai_thread.dart';
import '../shared/local_user.dart';

/// @title PlaceholderAiChat
/// @notice Fake data source for the Home AI overlay and history list.
class PlaceholderAiChat {
  // @dev Prevents instantiation of this utility holder.
  const PlaceholderAiChat._();

  /// @dev Shared lorem used for AI replies.
  static const String lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua.';

  /// @dev Alternate lorem lines cycled when the student re-prompts.
  static const List<String> replies = <String>[
    lorem,
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
        'nisi ut aliquip ex ea commodo consequat.',
    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum '
        'dolore eu fugiat nulla pariatur.',
  ];

  /// @notice Placeholder threads shown on Home and in the history overlay.
  /// @return Newest-activity-first threads.
  static List<AiThread> threads() {
    return <AiThread>[
      _thread(
        index: 1,
        title: 'Cari meja belajar',
        prompt: 'Tolong carikan meja belajar lipat dekat Ganesha.',
        timeLabel: '10:24',
      ),
      _thread(
        index: 2,
        title: 'Harga kipas angin',
        prompt: 'Berapa kisaran harga kipas angin meja bekas?',
        timeLabel: 'Kemarin',
      ),
      _thread(
        index: 3,
        title: 'Rekomendasi dispenser',
        prompt: 'Rekomendasi dispenser galon untuk kamar kos.',
        timeLabel: 'Sen',
      ),
      _thread(
        index: 4,
        title: 'Lokasi COD Ganesha',
        prompt: 'Di mana titik COD yang aman di ITB Ganesha?',
        timeLabel: '12 Agu',
      ),
    ];
  }

  /// @notice Picks the next lorem reply for a send or re-prompt.
  /// @param index Running counter from the notifier.
  /// @return A lorem paragraph.
  static String replyAt(int index) => replies[index % replies.length];

  /// @notice Builds the AI conversations seeded into the local cache.
  /// @param now UTC millis used as the reference time.
  /// @return Conversation companions, newest activity first.
  static List<AiConversationsCompanion> conversationRows({required int now}) {
    final List<AiThread> items = threads();
    return <AiConversationsCompanion>[
      for (int i = 0; i < items.length; i++)
        AiConversationsCompanion.insert(
          id: items[i].id,
          userId: const Value<String>(localUserId),
          title: Value<String>(items[i].title),
          lastMessageAt: Value<int>(_lastMessageMillis(now: now, index: i)),
          createdAt: Value<int>(_lastMessageMillis(now: now, index: i)),
          backendUpdatedAt: Value<int>(_lastMessageMillis(now: now, index: i)),
          updatedAt: Value<int>(now),
          lastFetched: Value<int>(now),
        ),
    ];
  }

  /// @notice Builds the AI bubbles seeded into the local cache.
  /// @dev One prompt bubble and one lorem answer per thread, mirroring
  /// {threads}.
  /// @param now UTC millis used as the reference time.
  /// @return Bubble companions, oldest first.
  static List<AiMessagesCompanion> messageRows({required int now}) {
    final List<AiMessagesCompanion> rows = <AiMessagesCompanion>[];
    final List<AiThread> items = threads();
    for (int i = 0; i < items.length; i++) {
      final AiThread item = items[i];
      final DateTime last = DateTime.fromMillisecondsSinceEpoch(
        _lastMessageMillis(now: now, index: i),
      );
      final String prompt = item.messages.first.text;
      rows.addAll(<AiMessagesCompanion>[
        AiMessagesCompanion.insert(
          id: '${item.id}-h',
          conversationId: item.id,
          role: const Value<String>('USER'),
          content: Value<String>(prompt),
          createdAt: Value<int>(
            last.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch,
          ),
        ),
        AiMessagesCompanion.insert(
          id: '${item.id}-a',
          conversationId: item.id,
          role: const Value<String>('ASSISTANT'),
          content: Value<String>(lorem),
          model: const Value<String>('kosply-placeholder'),
          createdAt: Value<int>(last.millisecondsSinceEpoch),
        ),
      ]);
    }
    return rows;
  }

  /// @dev Activity offsets of the placeholder threads.
  static const List<Duration> _threadOffsets = <Duration>[
    Duration.zero,
    Duration(days: 1),
    Duration(days: 5),
    Duration(days: 30),
  ];

  /// @notice Reference time of one placeholder thread.
  /// @dev The first thread pins to the most recent 10:24 so the history shows
  /// a stable clock label while a freshly persisted thread still sorts above
  /// it at any hour of the day.
  /// @param now UTC millis used as the reference time.
  /// @param index Zero-based thread slot.
  /// @return UTC millis of the thread's last bubble.
  static int _lastMessageMillis({required int now, required int index}) {
    if (index == 0) {
      final DateTime local = DateTime.fromMillisecondsSinceEpoch(now);
      final DateTime todayAt = DateTime(
        local.year,
        local.month,
        local.day,
        10,
        24,
      );
      final DateTime pinned = todayAt.isAfter(local)
          ? todayAt.subtract(const Duration(days: 1))
          : todayAt;
      return pinned.millisecondsSinceEpoch;
    }
    return now - _threadOffsets[index].inMilliseconds;
  }

  static AiThread _thread({
    required int index,
    required String title,
    required String prompt,
    required String timeLabel,
  }) {
    final String id = 'ai-$index';
    return AiThread(
      id: id,
      title: title,
      preview: lorem,
      timeLabel: timeLabel,
      messages: <AiMessage>[
        AiMessage(id: '$id-h', text: prompt, isMine: true),
        AiMessage(id: '$id-a', text: lorem, isMine: false),
      ],
    );
  }
}
