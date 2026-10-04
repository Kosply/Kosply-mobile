/// @title Settings screen tests
/// @notice Covers the settings hub: categories, role switch, dark mode, and
/// navigation into a detail destination.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/providers/theme_mode_provider.dart';
import 'package:kosply_mobile/screens/analytic_screen.dart';
import 'package:kosply_mobile/screens/app_setting_screen.dart';
import 'package:kosply_mobile/screens/contact_support_screen.dart';
import 'package:kosply_mobile/screens/favorite_screen.dart';
import 'package:kosply_mobile/screens/forgot_password_screen.dart';
import 'package:kosply_mobile/screens/help_desk_screen.dart';
import 'package:kosply_mobile/screens/profile_setting_screen.dart';
import 'package:kosply_mobile/screens/register_screen.dart';
import 'package:kosply_mobile/screens/settings_screen.dart';
import 'package:kosply_mobile/screens/splash_screen.dart';
import 'package:kosply_mobile/theme/kosply_theme.dart';
import 'package:kosply_mobile/widgets/settings_section_card.dart';

/// @notice Wraps [child] with Riverpod and the app themes.
/// @param child Widget under test.
/// @return The test app.
Widget _wrap(Widget child) {
  return ProviderScope(
    child: Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? _) {
        return MaterialApp(
          theme: KosplyTheme.light,
          darkTheme: KosplyTheme.dark,
          themeMode: ref.watch(themeModeProvider),
          home: child,
          routes: <String, WidgetBuilder>{
            HelpDeskScreen.routeName: (_) => const HelpDeskScreen(),
            ContactSupportScreen.routeName: (_) => const ContactSupportScreen(),
            FavoriteScreen.routeName: (_) => const FavoriteScreen(),
            AnalyticScreen.routeName: (_) => const AnalyticScreen(),
            ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
            SplashScreen.routeName: (_) => const SplashScreen(),
            RegisterScreen.routeName: (_) => const RegisterScreen(),
          },
        );
      },
    ),
  );
}

/// @notice Settings behaviour checks.
/// @return void
void main() {
  testWidgets('settings screen shows three categories and the role switch', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    expect(find.text('Setting'), findsOneWidget);
    expect(find.text('Pembeli'), findsOneWidget);
    expect(find.text('Penjual'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Aktivitas'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    expect(find.byType(SettingsSectionCard), findsNWidgets(3));
    expect(find.text('Profile setting'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('setting'), findsOneWidget);
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('Analytic'), findsNothing);
    expect(find.text('List catalog'), findsNothing);
    expect(find.text('Help desk'), findsOneWidget);
    expect(find.text('Contact support'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching to penjual updates the mode line', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    expect(find.textContaining('Mode pembeli'), findsOneWidget);

    await tester.tap(find.text('Penjual'));
    await tester.pump();

    expect(find.textContaining('Mode penjual'), findsOneWidget);
    expect(find.text('Analytic'), findsOneWidget);
  });

  testWidgets('dark mode switch flips the app theme', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('profile setting opens the profile form', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.tap(find.text('Profile setting'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSettingScreen), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Bio'), findsNothing);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('profile setting shows bio in penjual mode', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.tap(find.text('Penjual'));
    await tester.pump();
    await tester.tap(find.text('Profile setting'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSettingScreen), findsOneWidget);
    expect(find.text('Bio'), findsOneWidget);
  });

  testWidgets('setting row opens the account setting screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('setting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('setting'));
    await tester.pumpAndSettle();

    expect(find.byType(AppSettingScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppSettingScreen),
        matching: find.byType(SettingsSectionCard),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('setting-profile')), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('username'), findsOneWidget);
    expect(find.text('Notification'), findsOneWidget);
    expect(find.byKey(const Key('notify-mode')), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Personalisasi'), findsNothing);
    expect(find.text('Iklan'), findsNothing);
    expect(find.text('Ganti password'), findsOneWidget);
    expect(find.text('logout'), findsOneWidget);
  });

  testWidgets('setting profile row opens the profile form', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('setting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('setting'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('setting-profile')));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSettingScreen), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('personalisasi shows notification switches', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('setting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('setting'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notify-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personalisasi').last);
    await tester.pumpAndSettle();

    expect(find.text('Iklan'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('New message'), findsOneWidget);
    expect(find.byKey(const Key('notify-iklan')), findsOneWidget);
    expect(
      tester.widget<Switch>(find.byKey(const Key('notify-iklan'))).value,
      isTrue,
    );

    await tester.tap(find.byKey(const Key('notify-iklan')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Switch>(find.byKey(const Key('notify-iklan'))).value,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('notify-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All').last);
    await tester.pumpAndSettle();
    expect(find.text('Iklan'), findsNothing);
  });

  testWidgets('ganti password opens the existing reset flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('setting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('setting'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ganti password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ganti password'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.text('Forgot your password?'), findsOneWidget);
  });

  testWidgets('logout returns to the splash screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('setting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('setting'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('setting-logout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('setting-logout')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('favorite opens the favorite screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('Favorite'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorite'));
    await tester.pumpAndSettle();

    expect(find.byType(FavoriteScreen), findsOneWidget);
    expect(find.text('Cari favorite...'), findsOneWidget);
    expect(find.text('Belum ada barang favorite.'), findsOneWidget);
  });

  testWidgets('analytic opens the analytic screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.tap(find.text('Penjual'));
    await tester.pump();
    await tester.ensureVisible(find.text('Analytic'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analytic'));
    await tester.pumpAndSettle();

    expect(find.byType(AnalyticScreen), findsOneWidget);
    expect(find.text('Views'), findsOneWidget);
    expect(find.text('Trading product kamu'), findsOneWidget);
  });

  testWidgets('help desk opens the dropdown screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.tap(find.text('Help desk'));
    await tester.pumpAndSettle();

    expect(find.byType(HelpDeskScreen), findsOneWidget);
    expect(find.text('Barang tidak sesuai deskripsi'), findsOneWidget);
  });

  testWidgets('contact support opens the ticket inbox', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(const SettingsScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('Contact support'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contact support'));
    await tester.pumpAndSettle();

    expect(find.byType(ContactSupportScreen), findsOneWidget);
    expect(find.text('Cari ticket...'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });
}
