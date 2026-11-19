/// @title Settings screen tests
/// @notice Covers the settings hub: categories, role switch, dark mode, and
/// navigation into a detail destination.
/// @dev The hub ListView builds lazily. The surface is tall enough to build
/// the Support section under the notification and verification tiles.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/camera/providers/camera_provider.dart';
import 'package:kosply_mobile/providers/settings/theme_mode_provider.dart';
import 'package:kosply_mobile/screens/seller/analytic/analytic_screen.dart';
import 'package:kosply_mobile/screens/settings/app/app_setting_screen.dart';
import 'package:kosply_mobile/screens/support/contact/contact_support_screen.dart';
import 'package:kosply_mobile/screens/main/favorite/favorite_screen.dart';
import 'package:kosply_mobile/screens/auth/forgot_password/forgot_password_screen.dart';
import 'package:kosply_mobile/screens/support/help/help_desk_screen.dart';
import 'package:kosply_mobile/screens/settings/profile/profile_setting_screen.dart';
import 'package:kosply_mobile/screens/auth/register/register_screen.dart';
import 'package:kosply_mobile/screens/settings/hub/settings_screen.dart';
import 'package:kosply_mobile/screens/auth/onboarding/splash_screen.dart';
import 'package:kosply_mobile/theme/app/kosply_theme.dart';
import 'package:kosply_mobile/widgets/ai/overlay/ai_overlay_layer.dart';
import 'package:kosply_mobile/widgets/settings/card/settings_section_card.dart';

import 'helpers/fake_backend.dart';
import 'helpers/fake_listing_camera.dart';
import 'helpers/kosply_test_app.dart';

/// @notice A stored KTM application for the settings gate.
/// @param status `APPROVED`, `PENDING`, or `REJECTED`.
/// @param reason Reviewer note shown on the welcome card when rejected.
/// @return A backend whose `GET /api/verifications/me` returns that row.
FakeKosplyBackend _verification(String status, {String reason = ''}) {
  return FakeKosplyBackend()
    ..verification = <String, dynamic>{
      'id': 'verify-1',
      'status': status,
      'namaLengkap': 'Fajar Uji',
      'nim': '253140701111034',
      'universitas': 'Universitas Brawijaya',
      'programStudi': 'S1 Teknik Informatika',
      'rejectionReason': reason,
    };
}

/// @notice Wraps [home] with the app themes and the settings routes.
/// @param home Screen under test.
/// @return The test app.
Widget _app(Widget home) {
  return Consumer(
    builder: (BuildContext context, WidgetRef ref, Widget? _) {
      return MaterialApp(
        navigatorObservers: <NavigatorObserver>[aiRouteObserver],
        theme: KosplyTheme.light,
        darkTheme: KosplyTheme.dark,
        themeMode: ref.watch(themeModeProvider),
        home: home,
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
  );
}

/// @notice Settings behaviour checks.
/// @return void
void main() {
  testWidgets('settings screen shows three categories and the role switch', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

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

  testWidgets('switching to penjual opens welcome until review passes', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

    expect(find.textContaining('Mode pembeli'), findsOneWidget);
    expect(find.text('Verifikasi kampus'), findsNothing);

    await tester.tap(find.text('Penjual'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Verifikasi'), findsOneWidget);
    expect(find.text('Analytic'), findsNothing);
    expect(find.text('Setting'), findsNothing);

    final Offset icon = tester.getCenter(
      find.byKey(const Key('seller-welcome-icon')),
    );
    final Offset glyph = tester.getCenter(
      find.byKey(const Key('seller-welcome-glyph')),
    );
    expect((glyph - icon).distance, lessThan(1));
  });

  testWidgets('an approved seller opens seller settings', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(
      tester,
      const SettingsScreen(),
      app: _app,
      backend: _verification('APPROVED'),
    );

    await tester.tap(find.text('Penjual'));
    await tester.pumpAndSettle();

    expect(find.text('Setting'), findsOneWidget);
    expect(find.textContaining('Mode penjual'), findsOneWidget);
    expect(find.text('Analytic'), findsOneWidget);
    expect(find.text('Welcome'), findsNothing);
    expect(find.text('Verifikasi kampus'), findsNothing);
  });

  testWidgets('dark mode switch flips the app theme', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

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
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

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
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(
      tester,
      const SettingsScreen(),
      app: _app,
      backend: _verification('APPROVED'),
    );

    await tester.tap(find.text('Penjual'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile setting'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSettingScreen), findsOneWidget);
    expect(find.text('Bio'), findsOneWidget);
  });

  testWidgets('setting row opens the account setting screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

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
    expect(find.text('Kamu'), findsOneWidget);
    expect(find.text('@kamu'), findsOneWidget);
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
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

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
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

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
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

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
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

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
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

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
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(
      tester,
      const SettingsScreen(),
      app: _app,
      backend: _verification('APPROVED'),
    );

    await tester.tap(find.text('Penjual'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Analytic'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analytic'));
    await tester.pumpAndSettle();

    expect(find.byType(AnalyticScreen), findsOneWidget);
    expect(find.text('Views'), findsOneWidget);
    expect(find.text('Semua product kamu'), findsOneWidget);
    expect(find.byKey(const Key('analytic-empty-shelf')), findsOneWidget);
    expect(find.text('Trading product kamu'), findsNothing);
  });

  testWidgets('help desk opens the dropdown screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

    await tester.tap(find.text('Help desk'));
    await tester.pumpAndSettle();

    expect(find.byType(HelpDeskScreen), findsOneWidget);
    expect(find.text('Barang tidak sesuai deskripsi'), findsOneWidget);
  });

  testWidgets('contact support opens the ticket inbox', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SettingsScreen(), app: _app);

    await tester.ensureVisible(find.text('Contact support'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contact support'));
    await tester.pumpAndSettle();

    expect(find.byType(ContactSupportScreen), findsOneWidget);
    expect(find.text('Cari ticket...'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });

  testWidgets(
    'a pending seller refreshes welcome instead of opening settings',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1170, 3600);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await pumpKosplyApp(
        tester,
        const SettingsScreen(),
        app: _app,
        backend: _verification('PENDING'),
      );

      await tester.tap(find.text('Penjual'));
      await tester.pumpAndSettle();

      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Setting'), findsNothing);
      expect(find.byKey(const Key('seller-welcome-reason')), findsNothing);
    },
  );

  testWidgets('a rejected seller sees why under the welcome explanation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(
      tester,
      const SettingsScreen(),
      app: _app,
      backend: _verification('REJECTED', reason: 'Foto KTM buram.'),
    );

    await tester.tap(find.text('Penjual'));
    await tester.pumpAndSettle();

    expect(find.text('Foto KTM buram.'), findsOneWidget);
    expect(find.text('Verifikasi'), findsOneWidget);
    expect(find.text('Setting'), findsNothing);
  });

  testWidgets('verifikasi uploads a KTM and previews the card', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(
      tester,
      const SettingsScreen(),
      app: _app,
      overrides: [
        listingCameraFactoryProvider.overrideWithValue(FakeListingCamera.new),
      ],
    );

    await tester.tap(find.text('Penjual'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verifikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Verifikasi kampus'), findsOneWidget);
    expect(find.text('Nama lengkap'), findsNothing);
    expect(find.text('NIM'), findsNothing);
    expect(find.text('Universitas'), findsNothing);
    expect(find.text('Program studi'), findsNothing);
    expect(find.byKey(const Key('upload-nim-card')), findsOneWidget);
    expect(find.text('Lanjut'), findsNothing);

    final Offset icon = tester.getCenter(
      find.byKey(const Key('upload-nim-icon')),
    );
    final Offset glyph = tester.getCenter(
      find.byKey(const Key('upload-nim-glyph')),
    );
    expect((glyph - icon).distance, lessThan(1));

    await tester.tap(find.byKey(const Key('upload-nim-pick')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ktm-shutter')));
    await tester.pumpAndSettle();

    expect(find.text('Pratinjau KTM'), findsOneWidget);
    expect(find.byKey(const Key('ktm-camera-preview')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ktm-use')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ktm-preview')), findsOneWidget);
    expect(find.byKey(const Key('upload-nim-icon')), findsNothing);
    expect(find.text('Complete'), findsOneWidget);
  });
}
