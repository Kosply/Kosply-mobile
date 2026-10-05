/// @title AI thread
/// @notice Placeholder Home AI conversation used until a real assistant API
/// is wired up.
/// @author Kosply-mobile
library;

/// @title AiMessage
/// @notice One bubble in an AI thread.
class AiMessage {
  /// @notice Creates a bubble.
  /// @param id Stable identifier of the bubble.
  /// @param text Message body.
  /// @param isMine True when the signed-in student sent it.
  /// @return A new {AiMessage} instance.
  const AiMessage({required this.id, required this.text, required this.isMine});

  /// @dev Stable identifier of the bubble.
  final String id;

  /// @dev Message body.
  final String text;

  /// @dev True when the signed-in student sent it.
  final bool isMine;
}

/// @title AiThread
/// @notice One Home AI conversation, listed in chat history.
class AiThread {
  /// @notice Creates a thread.
  /// @param id Stable identifier of the thread.
  /// @param title Heading shown on the overlay and the Home list.
  /// @param preview Last line shown under the title on history rows.
  /// @param timeLabel Relative or clock label on history rows.
  /// @param messages Bubbles oldest-first.
  /// @return A new {AiThread} instance.
  const AiThread({
    required this.id,
    required this.title,
    required this.preview,
    required this.timeLabel,
    this.messages = const <AiMessage>[],
  });

  /// @dev Stable identifier of the thread.
  final String id;

  /// @dev Heading shown on the overlay and the Home list.
  final String title;

  /// @dev Last line shown under the title on history rows.
  final String preview;

  /// @dev Relative or clock label on history rows.
  final String timeLabel;

  /// @dev Bubbles oldest-first.
  final List<AiMessage> messages;

  /// @notice Copies this thread with selected fields replaced.
  /// @return A new {AiThread}.
  AiThread copyWith({
    String? title,
    String? preview,
    String? timeLabel,
    List<AiMessage>? messages,
  }) {
    return AiThread(
      id: id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      timeLabel: timeLabel ?? this.timeLabel,
      messages: messages ?? this.messages,
    );
  }
}
