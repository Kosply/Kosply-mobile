/// @title App smoke tests
/// @notice Verifies the app boots and the splash route reaches Register.
/// @author Kosply-mobile
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kosply_mobile/main.dart';
import 'package:kosply_mobile/screens/register_screen.dart';

/// @notice Smoke test suite.
/// @dev Pumps past the splash delay so no timer stays pending.
/// @return void
void main() {
  testWidgets('App boots and splash routes to Register', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}