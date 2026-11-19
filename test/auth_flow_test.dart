/// @title Auth flow tests
/// @notice Verifies the Google onboarding shortcut: email, password, and
/// verification steps are skipped, the session is stored, and the profile
/// lands in the cache. Also covers the session-aware splash and settings hub.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/storage/keys/storage_keys.dart';
import 'package:kosply_mobile/core/storage/providers/storage_providers.dart';
import 'package:kosply_mobile/layouts/main_layout.dart';
import 'package:kosply_mobile/main.dart';
import 'package:kosply_mobile/screens/auth/login/login_screen.dart';
import 'package:kosply_mobile/screens/auth/onboarding/interest_screen.dart';
import 'package:kosply_mobile/screens/auth/onboarding/splash_screen.dart';
import 'package:kosply_mobile/screens/auth/register/register_email_screen.dart';
import 'package:kosply_mobile/screens/auth/register/register_screen.dart';
import 'package:kosply_mobile/screens/settings/hub/settings_screen.dart';
import 'package:kosply_mobile/core/database/app_database.dart';
import 'package:kosply_mobile/core/database/providers/database_provider.dart';
import 'package:kosply_mobile/providers/account/session_provider.dart';

import 'helpers/fake_backend.dart';
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

/// @notice Boots the real app and waits for the splash to open register.
/// @dev Uses the app's own route table so back navigation is exercised on
/// the same stack the device builds.
/// @param tester The widget tester.
/// @return The seeded {ProviderContainer}.
Future<ProviderContainer> _bootApp(WidgetTester tester) async {
  _phone(tester);
  final ProviderContainer container = await pumpKosplyApp(
    tester,
    const SizedBox.shrink(),
    signedIn: false,
    app: (_) => const MyApp(),
  );
  await tester.pump(const Duration(seconds: 2));
  await _settle(tester);
  return container;
}

/// @notice Whether the root navigator could pop its top route.
/// @param tester The widget tester.
/// @return True when a route sits below the visible one.
bool _canPop(WidgetTester tester) {
  return tester.state<NavigatorState>(find.byType(Navigator).first).canPop();
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
      signedIn: false,
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
      FakeKosplyBackend.googleEmail,
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

    await pumpKosplyApp(
      tester,
      const RegisterEmailScreen(),
      signedIn: false,
    );

    expect(find.text("What's your email?"), findsOneWidget);
    expect(find.text("What's your name?"), findsNothing);
  });

  testWidgets('splash sends a signed-in session straight home', (
    WidgetTester tester,
  ) async {
    _phone(tester);

    final container = await seededContainer(signedIn: false);
    await container.read(sessionProvider.notifier).signInWithEmail(
      email: 'fajar@kampus.ac.id',
      password: 'rahasia123',
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

    final container = await seededContainer(signedIn: false);
    await container.read(sessionProvider.notifier).signInWithEmail(
      email: 'fajar@kampus.ac.id',
      password: 'rahasia123',
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
      signedIn: false,
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

  testWidgets('Back on the Google form cancels sign-up and reopens register', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await _bootApp(tester);

    await tester.tap(find.text('Continue with Google'));
    await _settle(tester);
    expect(find.text("What's your name?"), findsOneWidget);

    await tester.tap(find.text('Back'));
    await _settle(tester);

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(container.read(sessionProvider), isNull);
  });

  testWidgets('Back from login and email sign-up returns to register', (
    WidgetTester tester,
  ) async {
    await _bootApp(tester);

    await tester.tap(find.text('Sign in'));
    await _settle(tester);
    await tester.tap(find.text('Go back'));
    await _settle(tester);
    expect(find.byType(RegisterScreen), findsOneWidget);

    await tester.tap(find.text('Sign up with email'));
    await _settle(tester);
    await tester.tap(find.text('Back'));
    await _settle(tester);
    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('system back on a later step returns to the previous step', (
    WidgetTester tester,
  ) async {
    await _bootApp(tester);

    await tester.tap(find.text('Sign up with email'));
    await _settle(tester);
    await _step(tester, 'fajar@kampus.ac.id');
    expect(find.text("What's your name?"), findsOneWidget);

    await tester.binding.handlePopRoute();
    await _settle(tester);

    expect(find.byType(RegisterEmailScreen), findsOneWidget);
    expect(find.text("What's your email?"), findsOneWidget);
  });

  testWidgets('signing in leaves no auth screen behind home', (
    WidgetTester tester,
  ) async {
    await _bootApp(tester);

    await tester.tap(find.text('Sign in'));
    await _settle(tester);
    await tester.enterText(find.byType(TextField).first, 'fajar@kampus.ac.id');
    await tester.enterText(find.byType(TextField).last, 'rahasia123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await _settle(tester);

    expect(find.byType(KosplyMainLayout), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(_canPop(tester), isFalse);
  });

  testWidgets('email sign-up mails a code and registers with it', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    final FakeKosplyBackend backend = FakeKosplyBackend();
    await pumpKosplyApp(
      tester,
      const RegisterEmailScreen(),
      signedIn: false,
      backend: backend,
      routes: <String, WidgetBuilder>{
        InterestScreen.routeName: (_) => const InterestScreen(),
      },
    );

    await _step(tester, 'siswa@kampus.ac.id');
    await _step(tester, 'Fajar Arrizki');
    await _step(tester, 'fajararrizki');
    await _step(tester, 'secret12');

    expect(find.text('Check your inbox'), findsOneWidget);
    expect(backend.calls('POST', '/api/auth/email-code'), hasLength(1));

    await tester.ensureVisible(find.text('Resend code'));
    await tester.tap(find.text('Resend code'));
    await _settle(tester);
    expect(backend.calls('POST', '/api/auth/email-code'), hasLength(2));

    await _digits(tester, '0000');
    await tester.tap(find.text('Continue'));
    await _settle(tester);
    expect(find.text('Check your inbox'), findsOneWidget);
    expect(find.text('Kode salah atau sudah kedaluwarsa.'), findsOneWidget);

    await _digits(tester, '1234');
    await tester.tap(find.text('Continue'));
    await _settle(tester);
    expect(find.text('Your student number'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).keyboardType,
      TextInputType.number,
    );

    await _step(tester, '253140701111034');
    expect(find.text('Where do you study?'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).keyboardType,
      TextInputType.text,
    );

    await _step(tester, 'Universitas Indonesia 45');
    expect(find.text("What's your major?"), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).keyboardType,
      TextInputType.text,
    );
    await _step(tester, 'S1 Teknik Informatika');

    expect(find.byType(InterestScreen), findsOneWidget);
    final Map<String, dynamic> body = FakeKosplyBackend.bodyOf(
      backend.calls('POST', '/api/auth/register').single,
    );
    expect(body['code'], '1234');
    expect(body['email'], 'siswa@kampus.ac.id');
  });
}

/// @notice Fills the four code boxes, one digit each.
/// @param tester The widget tester.
/// @param code Four digits.
/// @return Future completing when the boxes show the code.
Future<void> _digits(WidgetTester tester, String code) async {
  final List<TextField> fields = tester
      .widgetList<TextField>(find.byType(TextField))
      .toList();
  expect(fields, hasLength(code.length));
  for (int i = 0; i < code.length; i++) {
    fields[i].controller!.text = code[i];
  }
  await tester.pump();
}
