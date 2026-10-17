/// @title UiBridgeScope
/// @notice Wraps a screen body and publishes it to the UI bridge registry so
/// the AI can read and drive the current screen.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui_bridge.dart';

/// @title UiBridgeScope
/// @notice Publishes [screen], [elements], and [selection] on every frame the
/// wrapped subtree rebuilds with changed values.
/// @dev Publishing runs in a post-frame callback because Riverpod forbids
/// modifying providers during build; {UiBridgeNotifier.publish} ignores
/// identical publishes, so repeated frames are cheap.
class UiBridgeScope extends ConsumerStatefulWidget {
  /// @notice Creates a publishing scope.
  /// @param screen Screen name, e.g. `home`.
  /// @param child Wrapped screen body.
  /// @param elements Addressable elements currently visible.
  /// @param selection Active selection, e.g. filters.
  /// @return A new {UiBridgeScope} instance.
  const UiBridgeScope({
    required this.screen,
    required this.child,
    this.elements = const <UiElement>[],
    this.selection = const <String, Object?>{},
    super.key,
  });

  /// @dev Screen name.
  final String screen;

  /// @dev Wrapped screen body.
  final Widget child;

  /// @dev Addressable elements.
  final List<UiElement> elements;

  /// @dev Active selection.
  final Map<String, Object?> selection;

  /// @notice Creates the publishing state.
  /// @return The {_UiBridgeScopeState} instance.
  @override
  ConsumerState<UiBridgeScope> createState() => _UiBridgeScopeState();
}

/// @title _UiBridgeScopeState
/// @notice Publishes the latest snapshot after each frame.
class _UiBridgeScopeState extends ConsumerState<UiBridgeScope> {
  /// @notice Publishes the current snapshot once the frame completes.
  /// @param context The build context.
  /// @return The wrapped child.
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref
          .read(uiBridgeProvider.notifier)
          .publish(
            screen: widget.screen,
            elements: widget.elements,
            selection: widget.selection,
          );
    });
    return widget.child;
  }
}
