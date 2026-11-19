/// @title UI commands
/// @notice Queue of screen actions the agent returned, plus the card the
/// host should flash.
/// @dev The chat notifier only enqueues. {UiCommandHost} runs the queue with
/// a real navigator so a provider never pushes a route itself.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/chat/ai_turn.dart';

/// @title UiCommandNotifier
/// @notice Append-only queue of callbacks waiting to run.
class UiCommandNotifier extends Notifier<List<UiCallback>> {
  /// @notice Starts empty.
  /// @return An empty queue.
  @override
  List<UiCallback> build() => const <UiCallback>[];

  /// @notice Appends [callbacks] for the host to run.
  /// @param callbacks Actions from the latest turn, in order.
  /// @return void
  void enqueue(List<UiCallback> callbacks) {
    if (callbacks.isEmpty) {
      return;
    }
    state = <UiCallback>[...state, ...callbacks];
  }

  /// @notice Takes the queue and leaves it empty.
  /// @return The callbacks that were waiting.
  List<UiCallback> take() {
    final List<UiCallback> pending = state;
    state = const <UiCallback>[];
    return pending;
  }
}

/// @dev Callbacks the host has not run yet.
final uiCommandsProvider =
    NotifierProvider<UiCommandNotifier, List<UiCallback>>(
      UiCommandNotifier.new,
    );

/// @title UiHighlightNotifier
/// @notice Product id whose card is briefly outlined.
class UiHighlightNotifier extends Notifier<String> {
  Timer? _timer;

  /// @notice Starts with nothing highlighted.
  /// @return An empty id.
  @override
  String build() {
    ref.onDispose(() => _timer?.cancel());
    return '';
  }

  /// @notice Outlines [id] and clears it shortly after.
  /// @param id Product id, without the `product:` prefix.
  /// @return void
  void flash(String id) {
    _timer?.cancel();
    state = id;
    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (state == id) {
        state = '';
      }
    });
  }
}

/// @dev Product id currently outlined, or empty.
final uiHighlightProvider = NotifierProvider<UiHighlightNotifier, String>(
  UiHighlightNotifier.new,
);

/// @title UiAnchors
/// @notice Global keys for elements the AI may scroll to.
class UiAnchors {
  final Map<String, GlobalKey> _keys = <String, GlobalKey>{};

  /// @notice The key for [id], created on first use.
  /// @param id Convention id, e.g. `product:<id>`.
  /// @return A stable {GlobalKey}.
  GlobalKey of(String id) => _keys.putIfAbsent(id, GlobalKey.new);
}

/// @dev Keys shared by cards and the command host.
final uiAnchorsProvider = Provider<UiAnchors>((Ref ref) => UiAnchors());
