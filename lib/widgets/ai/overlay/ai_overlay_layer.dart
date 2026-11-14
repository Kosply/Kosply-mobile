/// @title AI overlay layer
/// @notice Puts the AI control on top of a screen the agent can drive.
/// @dev The tab shell stays mounted under a pushed product, so both hosts
/// exist at once. The covered host hides itself. That keeps a single brain
/// control and a single dismiss scrim.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/chat/ai_chat_provider.dart';
import 'ai_home_overlay.dart';

/// @dev Notifies overlay hosts when a route covers them.
/// Register this on every {MaterialApp} that can show the AI control.
final RouteObserver<ModalRoute<void>> aiRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// @title AiOverlayLayer
/// @notice Stacks the AI control over [child], on the right.
class AiOverlayLayer extends ConsumerStatefulWidget {
  /// @notice Creates a layer over [child].
  /// @param child Screen body.
  /// @return A new {AiOverlayLayer} instance.
  const AiOverlayLayer({required this.child, super.key});

  /// @dev Screen body.
  final Widget child;

  /// @notice Creates the route-aware state.
  /// @return The {_AiOverlayLayerState} instance.
  @override
  ConsumerState<AiOverlayLayer> createState() => _AiOverlayLayerState();
}

/// @title _AiOverlayLayerState
/// @notice Hides the control while another route covers this host.
class _AiOverlayLayerState extends ConsumerState<AiOverlayLayer>
    with RouteAware {
  bool _covered = false;
  ModalRoute<void>? _route;

  /// @notice Subscribes to the route that owns this host.
  /// @return void
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<void>? next = ModalRoute.of(context);
    if (next == _route) {
      return;
    }
    if (_route != null) {
      aiRouteObserver.unsubscribe(this);
    }
    _route = next;
    if (next != null) {
      aiRouteObserver.subscribe(this, next);
    }
  }

  /// @notice Drops the route subscription.
  /// @return void
  @override
  void dispose() {
    aiRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// @notice A route was pushed on top of this host.
  /// @return void
  @override
  void didPushNext() {
    if (!_covered) {
      setState(() => _covered = true);
    }
  }

  /// @notice The route on top was popped. This host is visible again.
  /// @return void
  @override
  void didPopNext() {
    if (_covered) {
      setState(() => _covered = false);
    }
  }

  /// @notice Builds [child] and, when this route is current, the AI control.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The stack.
  @override
  Widget build(BuildContext context) {
    final AiChatState ai = ref.watch(aiChatProvider);
    final bool panelOpen = ai.composerOpen || ai.panel != AiPanelKind.hidden;

    return Stack(
      children: [
        widget.child,
        if (!_covered && panelOpen)
          Positioned.fill(
            child: GestureDetector(
              key: const Key('ai-dismiss'),
              behavior: HitTestBehavior.opaque,
              onTap: () => ref.read(aiChatProvider.notifier).close(),
            ),
          ),
        if (!_covered)
          const Align(
            alignment: Alignment.bottomRight,
            child: AiHomeOverlay(),
          ),
      ],
    );
  }
}
