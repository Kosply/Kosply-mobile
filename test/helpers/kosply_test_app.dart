/// @title Kosply test app helper
/// @notice Seeds the in-memory cache and pumps a screen inside the same
/// Riverpod scope the app uses.
/// @dev Widget tests call {pumpKosplyApp} so screens read the same seeded
/// Drift data the device shows on first launch.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/providers/seed/app_seeder_provider.dart';

/// @notice Creates a scope with every cache seeded.
/// @dev Disposed automatically at test end.
/// @return The ready {ProviderContainer}.
Future<ProviderContainer> seededContainer() async {
  final ProviderContainer container = ProviderContainer();
  addTearDown(container.dispose);
  await container.read(appSeederProvider).seedIfEmpty();
  return container;
}

/// @notice Pumps [home] inside a seeded app scope.
/// @dev The trailing duration pump fires drift's zero-duration stream
/// bookkeeping timers, which plain {WidgetTester.pump} would leave pending.
/// @param tester The widget tester.
/// @param home Screen under test.
/// @param routes Extra named routes.
/// @param onGenerateRoute Route factory for argument routes.
/// @param app Replaces the default {MaterialApp} builder, e.g. to inject the
/// app themes around [home].
/// @param container Pre-seeded container to reuse, e.g. after signing in.
/// @return The seeded {ProviderContainer}.
Future<ProviderContainer> pumpKosplyApp(
  WidgetTester tester,
  Widget home, {
  Map<String, WidgetBuilder>? routes,
  RouteFactory? onGenerateRoute,
  Widget Function(Widget home)? app,
  ProviderContainer? container,
}) async {
  final ProviderContainer scope = container ?? await seededContainer();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: scope,
      child:
          app?.call(home) ??
          MaterialApp(
            home: home,
            routes: routes ?? const <String, WidgetBuilder>{},
            onGenerateRoute: onGenerateRoute,
          ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 20));
  await tester.pump(const Duration(milliseconds: 20));
  await tester.pump();
  return scope;
}
