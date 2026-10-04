/// @title Placeholder AI chat
/// @notice Stand-in Home AI threads until an assistant API is wired up.
/// @author Kosply-mobile
library;

import '../models/ai_thread.dart';

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
