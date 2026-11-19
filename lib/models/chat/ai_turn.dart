/// @title AI turn
/// @notice The answer and screen callbacks returned by one `POST /api/ai/chat`.
/// @dev {callbacks} is what the model asked Flutter to run. Unknown names are
/// dropped by the command host.
/// @author Kosply-mobile
library;

import '../../core/network/json_read.dart';
import 'listing_proposal.dart';

/// @title UiCallback
/// @notice One safe screen action from the agent.
class UiCallback {
  /// @notice Creates a callback.
  /// @param name Safe name, e.g. `open_product`.
  /// @param args Arguments the model passed. The wire key is `args`.
  /// @return A new {UiCallback} instance.
  const UiCallback({required this.name, this.args = const <String, Object?>{}});

  /// @dev Safe callback name.
  final String name;

  /// @dev Arguments the model passed.
  final Map<String, Object?> args;

  /// @notice Reads one entry of a turn's `callbacks` list.
  /// @param json One callback object.
  /// @return The callback, or null when it has no name.
  static UiCallback? fromJson(Map<String, dynamic> json) {
    final String name = json.str('callback');
    if (name.isEmpty) {
      return null;
    }
    final Object? raw = json['args'];
    final Map<String, Object?> args = raw is Map
        ? raw.map(
            (Object? key, Object? value) =>
                MapEntry<String, Object?>(key.toString(), value),
          )
        : const <String, Object?>{};
    return UiCallback(name: name, args: args);
  }
}

/// @title AiTurn
/// @notice Text answer plus the callbacks that should move the screen.
class AiTurn {
  /// @notice Creates a turn result.
  /// @param answer Text shown in the chat bubble.
  /// @param callbacks Screen actions, in the order the model emitted them.
  /// @return A new {AiTurn} instance.
  const AiTurn({
    required this.answer,
    this.thinking = '',
    this.callbacks = const <UiCallback>[],
    this.needsApproval = false,
    this.draft = '',
    this.proposal,
  });

  /// @dev Text shown in the chat bubble.
  final String answer;

  /// @dev Reasoning text collected from `thinking` events.
  final String thinking;

  /// @dev Screen actions, in order.
  final List<UiCallback> callbacks;

  /// @dev True when the stream ended on an approval interrupt.
  final bool needsApproval;

  /// @dev Message text the approval will send. Empty on an ordinary turn.
  final String draft;

  /// @dev Seller form waiting for Setujui. Null when this turn is not one.
  final ListingProposal? proposal;

  /// @notice Reads a chat response body.
  /// @param json Decoded `POST /api/ai/chat` body.
  /// @return The turn.
  factory AiTurn.fromJson(Map<String, dynamic> json) {
    return AiTurn(
      answer: json.str('answer'),
      callbacks: <UiCallback>[
        for (final Map<String, dynamic> item in json.objects('callbacks'))
          if (UiCallback.fromJson(item) case final UiCallback callback)
            callback,
      ],
    );
  }
}
