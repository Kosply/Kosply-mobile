/// @title Auth flow tests
/// @notice Verifies the Google onboarding shortcut: email, password, and
/// verification steps are skipped, the session is stored, and the profile
/// lands in the cache. Also covers the session-aware splash and settings hub.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/storage/keys/storage_keys.dart';
import 'package:kosply_mobile/core/storage/providers/storage_providers.dart';
import 'package:kosply_mobile/layouts/main_layout.dart';
import 'package:kosply_mobile/screens/auth/login/login_screen.dart';
import 'package:kosply_mobile/screens/auth/onboarding/interest_screen.dart';
import 'package:kosply_mobile/screens/auth/onboarding/splash_screen.dart';
import 'package:kosply_mobile/screens/auth/register/register_email_screen.dart';
import 'package:kosply_mobile/screens/auth/register/register_screen.dart';
import 'package:kosply_mobile/screens/settings/hub/settings_screen.dart';
import 'package:kosply_mobile/core/database/app_database.dart';
import 'package:kosply_mobile/core/database/providers/database_provider.dart';
import 'package:kosply_mobile/data/account/session_repository.dart';
import 'package:kosply_mobile/providers/account/session_provider.dart';

import 'helpers/kosply_test_app.dart';

/// @notice Sets a phone-sized viewport for every widget test.
/// @param tester The widget tester.
/// @return void
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2100);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// @notice Drains microtasks and drift's zero-duration timers.
/// @dev The stepped form schedules no frame on the last step, so a plain
/// {WidgetTester.pumpAndSettle} would stop before the save chain runs.
/// @param tester The widget tester.
/// @return Future completing when the tree settles.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

/// @notice Walks one step: types [value] and taps Continue.
/// @param tester The widget tester.
/// @param value Text for the active step.
/// @return Future completing after the step renders.
Future<void> _step(WidgetTester tester, String value) async {
  await tester.enterText(find.byType(TextField).first, value);
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await _settle(tester);
}

/// @notice Auth flow checks.
/// @return void
void main() {
  testWidgets('google sign-in skips email, password, and verification', (
    WidgetTester tester,
  ) async {
    _phone(tester);

    final container = await pumpKosplyApp(
      tester,
      const RegisterScreen(),
      routes: <String, WidgetBuilder>{
        RegisterEmailScreen.googleRouteName: (_) =>
            const RegisterEmailScreen(googleFlow: true),
        InterestScreen.routeName: (_) => const InterestScreen(),
        KosplyMainLayout.routeName: (_) => const Text('HOME'),
      },
    );

    await tester.tap(find.text('Continue with Google'));
    await _settle(tester);

    expect(find.text("What's your name?"), findsOneWidget);
    expect(find.text("What's your email?"), findsNothing);
    expect(find.text('Lock it down'), findsNothing);
    expect(find.text('Check your inbox'), findsNothing);
    expect(
      container.read(sessionProvider)?.email,
      SessionRepository.googleDemoEmail,
    );

    await _step(tester, 'Fajar Arrizki');
    await _step(tester, 'fajararrizki');
    await _step(tester, '253140701111034');
    await _step(tester, 'Universitas Indonesia 45');
    await _step(tester, 'S1 Teknik Informatika');

    expect(find.byType(InterestScreen), findsOneWidget);
    expect(container.read(sessionProvider)?.onboardingRequired, isFalse);
    final UserRow? row = await container
        .read(appDatabaseProvider)
        .accountDao
        .profileOnce();
    expect(row?.name, 'Fajar Arrizki');
    expect(
      await container.read(secureStoreProvider).read(StorageKeys.accessToken),
      isNotEmpty,
    );
  });

  testWidgets('email registration still starts with the email step', (
    WidgetTester tester,
  ) async {
    _phone(tester);

    await pumpKosplyApp(tester, const RegisterEmailScreen());

    expect(find.text("What's your email?"), findsOneWidget);
    expect(find.text("What's your name?"), findsNothing);
  });

  testWidgets('splash sends a signed-in session straight home', (
    WidgetTester tester,
  ) async {
    _phone(tester);

    final container = await seededContainer();
    await container.read(sessionProvider.notifier).signInWithEmail(
          email: 'fajar@kampus.ac.id',
        );

    await pumpKosplyApp(
      tester,
      const SplashScreen(),
      container: container,
      routes: <String, WidgetBuilder>{
        KosplyMainLayout.routeName: (_) => const Text('HOME'),
        RegisterScreen.routeName: (_) => const Text('REGISTER'),
      },
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('settings hub reflects the signed-in email', (
    WidgetTester tester,
  ) async {
    _phone(tester);

    final container = await seededContainer();
    await container.read(sessionProvider.notifier).signInWithEmail(
          email: 'fajar@kampus.ac.id',
        );

    await pumpKosplyApp(
      tester,
      const SettingsScreen(),
      container: container,
    );

    expect(find.textContaining('fajar@kampus.ac.id'), findsOneWidget);
  });

  testWidgets('signing in from the login screen opens home', (
    WidgetTester tester,
  ) async {
    _phone(tester);

    final container = await pumpKosplyApp(
      tester,
      const LoginScreen(),
      routes: <String, WidgetBuilder>{
        KosplyMainLayout.routeName: (_) => const Text('HOME'),
      },
    );

    await tester.enterText(
      find.byType(TextField).first,
      'fajar@kampus.ac.id',
    );
    await tester.enterText(find.byType(TextField).last, 'rahasia123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(
      container.read(sessionProvider)?.email,
      'fajar@kampus.ac.id',
    );
  });
}
