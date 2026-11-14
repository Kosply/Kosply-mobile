/// @title Kosply test app helper
/// @notice Points widget tests at {FakeKosplyBackend} and pumps a screen
/// inside the same Riverpod scope the app uses.
/// @dev The cache is filled by {AppSync}, so screens run the real repository
/// mapping instead of a local seeder.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/auth/google_id_token.dart';
import 'package:kosply_mobile/providers/account/session_provider.dart';
import 'package:kosply_mobile/providers/network/api_provider.dart';
import 'package:kosply_mobile/providers/sync/app_sync_provider.dart';
import 'package:kosply_mobile/widgets/ai/overlay/ai_overlay_layer.dart';

import 'fake_backend.dart';

/// @title _FixedGoogleIdToken
/// @notice Google picker that never opens a platform account sheet.
class _FixedGoogleIdToken implements GoogleIdTokenSource {
  @override
  Future<String> idToken() async => 'test-google-id-token';
}

/// @notice Creates a scope whose HTTP client is the in-memory backend.
/// @dev When [signedIn] is true the student `me@kampus.ac.id` is signed in
/// and the account cache is refreshed before the container is returned.
/// Public catalogue and FAQ are always synced.
/// @param overrides Provider overrides, e.g. a fake camera.
/// @param signedIn Whether to open a session before the screen builds.
/// @return The ready {ProviderContainer}.
Future<ProviderContainer> seededContainer({
  List<Override> overrides = const <Override>[],
  bool signedIn = true,
  FakeKosplyBackend? backend,
}) async {
  final FakeKosplyBackend api = backend ?? FakeKosplyBackend();
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      httpClientProvider.overrideWithValue(api.client),
      apiBaseUrlProvider.overrideWithValue(FakeKosplyBackend.origin),
      googleIdTokenSourceProvider.overrideWithValue(_FixedGoogleIdToken()),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  if (signedIn) {
    await container
        .read(sessionProvider.notifier)
        .signInWithEmail(email: 'me@kampus.ac.id', password: 'password');
  }
  await container.read(appSyncProvider).syncAll();
  return container;
}

/// @notice Pumps [home] inside a backend-backed app scope.
/// @dev The trailing duration pump fires drift's zero-duration stream
/// bookkeeping timers, which plain {WidgetTester.pump} would leave pending.
/// @param tester The widget tester.
/// @param home Screen under test.
/// @param routes Extra named routes.
/// @param onGenerateRoute Route factory for argument routes.
/// @param app Replaces the default {MaterialApp} builder, e.g. to inject the
/// app themes around [home].
/// @param container Pre-seeded container to reuse, e.g. after signing in.
/// @param signedIn Whether a fresh container signs in. Ignored when
/// [container] is passed.
/// @param overrides Provider overrides for a fresh container.
/// @return The seeded {ProviderContainer}.
Future<ProviderContainer> pumpKosplyApp(
  WidgetTester tester,
  Widget home, {
  Map<String, WidgetBuilder>? routes,
  RouteFactory? onGenerateRoute,
  Widget Function(Widget home)? app,
  ProviderContainer? container,
  bool signedIn = true,
  List<Override> overrides = const <Override>[],
  FakeKosplyBackend? backend,
}) async {
  final ProviderContainer scope =
      container ??
      await seededContainer(
        signedIn: signedIn,
        overrides: overrides,
        backend: backend,
      );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: scope,
      child:
          app?.call(home) ??
          MaterialApp(
            navigatorObservers: <NavigatorObserver>[aiRouteObserver],
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
