/// @title AI overlay layer
/// @notice One AI control for the whole app, painted above the navigator.
/// @dev Screen changes swap the route underneath. This layer stays mounted,
/// so the open panel, the draft, and the scroll position do not reset.
/// Auth and camera routes hide it without disposing that state.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/chat/ai_chat_provider.dart';
import '../../../providers/location/location_label_provider.dart';
import 'ai_home_overlay.dart';

/// @dev Notifies shell and pushed screens when a route covers them.
/// Register this on every {MaterialApp} that can show the AI control.
final RouteObserver<ModalRoute<void>> aiRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// @dev Routes where the control is hidden. The widget stays mounted.
const Set<String> aiOverlayHiddenRoutes = <String>{
  '/splash',
  '/register',
  '/register-email',
  '/register-google',
  '/login',
  '/forgot-password',
  '/interest',
  '/product-camera',
  '/ktm-camera',
};

/// @dev How far the shell navigation bar lifts the control.
const double kShellNavGap = 80;

/// @dev How far a pinned 52px action bar lifts the control.
const double kBottomBarGap = 72;

/// @dev How far a chat composer lifts the control.
const double kComposerGap = 64;

/// @title AiOverlayGate
/// @notice Whether the control is painted. Hidden routes keep the state.
class AiOverlayGate extends Notifier<bool> {
  /// @notice Hidden until a signed-in route reports itself.
  /// @return false.
  @override
  bool build() => false;

  /// @notice Shows or hides the control.
  /// @param value True on an ordinary screen.
  /// @return void
  void allow(bool value) {
    if (state != value) {
      state = value;
    }
  }
}

/// @dev Visibility of the single AI control.
final aiOverlayGateProvider = NotifierProvider<AiOverlayGate, bool>(
  AiOverlayGate.new,
);

/// @title AiOverlayGap
/// @notice Extra bottom inset so the control clears a pinned bar.
class AiOverlayGap extends Notifier<double> {
  /// @notice No bar until a route reports one.
  /// @return 0.
  @override
  double build() => 0;

  /// @notice Sets the inset in logical pixels.
  /// @param value Gap above the safe area.
  /// @return void
  void set(double value) {
    if (state != value) {
      state = value;
    }
  }
}

/// @dev Bottom gap reported by the current route.
final aiOverlayGapProvider = NotifierProvider<AiOverlayGap, double>(
  AiOverlayGap.new,
);

/// @title AiOverlayNavigatorObserver
/// @notice Tells [aiOverlayGateProvider] which route is on top.
class AiOverlayNavigatorObserver extends NavigatorObserver {
  /// @notice Creates the observer.
  AiOverlayNavigatorObserver();

  /// @notice The top route changed.
  /// @param topRoute The route now on top.
  /// @param previousTopRoute The route that was on top.
  /// @return void
  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    final NavigatorState? nav = navigator;
    if (nav == null) {
      return;
    }
    // A dialog, menu, or dropdown is a popup. Hide the control while it is
    // up so the sheet stays on top, and keep the same overlay state.
    final bool allow =
        topRoute is! PopupRoute<dynamic> &&
        !aiOverlayHiddenRoutes.contains(topRoute.settings.name ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!nav.mounted) {
        return;
      }
      ProviderScope.containerOf(nav.context)
          .read(aiOverlayGateProvider.notifier)
          .allow(allow);
    });
  }
}

/// @dev Shared by [MyApp] and the widget-test app. One navigator at a time.
final AiOverlayNavigatorObserver aiOverlayNavigatorObserver =
    AiOverlayNavigatorObserver();

/// @title AiOverlayLayer
/// @notice Stacks the AI control over [child].
/// @dev The control sits in its own [Overlay] so the composer can show a
/// selection toolbar. That entry stays mounted across route changes.
class AiOverlayLayer extends ConsumerStatefulWidget {
  /// @notice Creates a layer over [child].
  /// @param child The navigator, or a screen in a test that builds its own.
  /// @return A new {AiOverlayLayer} instance.
  const AiOverlayLayer({required this.child, super.key});

  /// @dev Content under the control.
  final Widget child;

  /// @notice Creates the overlay entry.
  /// @return The {_AiOverlayLayerState} instance.
  @override
  ConsumerState<AiOverlayLayer> createState() => _AiOverlayLayerState();
}

/// @title _AiOverlayLayerState
/// @notice Owns the one overlay entry painted above [AiOverlayLayer.child].
class _AiOverlayLayerState extends ConsumerState<AiOverlayLayer> {
  late final OverlayEntry _entry = OverlayEntry(builder: _paint);

  /// @notice Paints the control. Hidden routes keep this entry mounted.
  /// @param context The overlay context.
  /// @return The control, or an offstage copy on auth and camera routes.
  Widget _paint(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? _) {
        final bool allowed = ref.watch(aiOverlayGateProvider);
        final AiChatState ai = ref.watch(aiChatProvider);
        final bool panelOpen =
            ai.composerOpen || ai.panel != AiPanelKind.hidden;
        return Offstage(
          offstage: !allowed,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (panelOpen)
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  // Leave the pinned bar tappable. The bar sits above the
                  // keyboard, and [gap] is its height without the system inset.
                  bottom: () {
                    final double keyboard = MediaQuery.viewInsetsOf(context)
                        .bottom;
                    final double safe = MediaQuery.paddingOf(context).bottom;
                    final double gap = ref.watch(aiOverlayGapProvider);
                    final double inset = keyboard > safe ? keyboard : safe;
                    return inset + gap;
                  }(),
                  child: GestureDetector(
                    key: const Key('ai-dismiss'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ref.read(aiChatProvider.notifier).close(),
                  ),
                ),
              const Align(
                alignment: Alignment.bottomRight,
                child: AiHomeOverlay(key: Key('ai-home-overlay')),
              ),
            ],
          ),
        );
      },
    );
  }

  /// @notice Builds [child] and the overlay that holds the control.
  /// @param context The build context.
  /// @return The stack.
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Overlay(initialEntries: <OverlayEntry>[_entry]),
      ],
    );
  }
}

/// @title RouteGapHost
/// @notice Publishes this route's bottom-bar height while it is on top.
/// @dev A covered route clears the gap so a plain page sits the control on
/// the safe area. The page that is coming back publishes its own gap in
/// [didPopNext], and the page that is leaving does not overwrite it.
class RouteGapHost extends ConsumerStatefulWidget {
  /// @notice Creates a host around [child].
  /// @param gap Bar height, excluding the system inset.
  /// @param child The route body.
  /// @param resolveLocation Whether this is the home shell, which asks for
  /// the device location the first time it is shown.
  /// @return A new {RouteGapHost} instance.
  const RouteGapHost({
    required this.gap,
    required this.child,
    this.resolveLocation = false,
    super.key,
  });

  /// @dev Bar height, excluding the system inset.
  final double gap;

  /// @dev The route body.
  final Widget child;

  /// @dev Whether showing this route should ask for location once.
  final bool resolveLocation;

  /// @notice Creates the route-aware state.
  /// @return The {_RouteGapHostState} instance.
  @override
  ConsumerState<RouteGapHost> createState() => _RouteGapHostState();
}

/// @title _RouteGapHostState
/// @notice Subscribes to [aiRouteObserver] and publishes [RouteGapHost.gap].
class _RouteGapHostState extends ConsumerState<RouteGapHost> with RouteAware {
  ModalRoute<void>? _route;

  /// @notice Subscribes when the enclosing route is known.
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

  /// @notice Drops the subscription.
  /// @return void
  @override
  void dispose() {
    aiRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// @notice This route is on top.
  /// @return void
  @override
  void didPush() => _show();

  /// @notice The route above was popped. This route is on top again.
  /// @return void
  @override
  void didPopNext() => _show();

  /// @notice Something was pushed on top. Clear the gap until that page
  /// publishes its own.
  /// @return void
  @override
  void didPushNext() => _publish(0);

  void _show() {
    _publish(widget.gap);
    if (!widget.resolveLocation) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(locationLabelProvider.notifier).resolve();
    });
  }

  void _publish(double value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(aiOverlayGapProvider.notifier).set(value);
    });
  }

  /// @notice Builds [child].
  /// @param context The build context.
  /// @return The child.
  @override
  Widget build(BuildContext context) => widget.child;
}
