/// @title Screen render tests
/// @notice Verifies that every screen builds without layout errors.
/// @dev Uses the shared widgets, so a regression in the shell, the form bar,
/// or the input styling fails here instead of on a device.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/main.dart';
import 'package:kosply_mobile/screens/forgot_password_screen.dart';
import 'package:kosply_mobile/screens/interest_screen.dart';
import 'package:kosply_mobile/screens/login_screen.dart';
import 'package:kosply_mobile/screens/register_email_screen.dart';
import 'package:kosply_mobile/screens/register_screen.dart';
import 'package:kosply_mobile/screens/splash_screen.dart';

/// @notice Screen-by-screen render checks.
/// @return void
void main() {
  /// @dev Screens that do not start a timer, so they can be pumped directly.
  final screens = <String, Widget>{
    'register': const RegisterScreen(),
    'login': const LoginScreen(),
    'register email': const RegisterEmailScreen(),
    'forgot password': const ForgotPasswordScreen(),
    'interest': const InterestScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} screen renders without layout errors', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2100);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(home: entry.value));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('splash screen renders and drains its timer', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // @dev Uses the app shell so the /register route resolves after the timer.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}