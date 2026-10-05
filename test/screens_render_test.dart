/// @title Screen render tests
/// @notice Verifies that every screen builds without layout errors.
/// @dev Uses the shared widgets, so a regression in the shell, the form bar,
/// or the input styling fails here instead of on a device.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/data/placeholder_catalog.dart';
import 'package:kosply_mobile/layouts/main_layout.dart';
import 'package:kosply_mobile/main.dart';
import 'package:kosply_mobile/screens/forgot_password_screen.dart';
import 'package:kosply_mobile/screens/home_screen.dart';
import 'package:kosply_mobile/screens/interest_screen.dart';
import 'package:kosply_mobile/screens/login_screen.dart';
import 'package:kosply_mobile/screens/product_view_screen.dart';
import 'package:kosply_mobile/screens/profile_setting_screen.dart';
import 'package:kosply_mobile/screens/register_email_screen.dart';
import 'package:kosply_mobile/screens/register_screen.dart';
import 'package:kosply_mobile/screens/add_product_screen.dart';
import 'package:kosply_mobile/screens/app_setting_screen.dart';
import 'package:kosply_mobile/screens/analytic_screen.dart';
import 'package:kosply_mobile/screens/chat_detail_screen.dart';
import 'package:kosply_mobile/screens/favorite_screen.dart';
import 'package:kosply_mobile/screens/contact_support_screen.dart';
import 'package:kosply_mobile/screens/create_ticket_screen.dart';
import 'package:kosply_mobile/screens/help_desk_screen.dart';
import 'package:kosply_mobile/screens/inbox_screen.dart';
import 'package:kosply_mobile/screens/jual_screen.dart';
import 'package:kosply_mobile/screens/search_screen.dart';
import 'package:kosply_mobile/screens/see_all_screen.dart';
import 'package:kosply_mobile/screens/seller_detail_screen.dart';
import 'package:kosply_mobile/screens/settings_screen.dart';
import 'package:kosply_mobile/screens/splash_screen.dart';
import 'package:kosply_mobile/screens/ticket_detail_screen.dart';
import 'package:kosply_mobile/widgets/kosply_wordmark.dart';
import 'package:kosply_mobile/widgets/product_grid.dart';

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
    'see all': SeeAllScreen(
      title: 'Rekomendasi',
      items: PlaceholderCatalog.all(),
    ),
    'product view': const ProductViewScreen(productId: 'product-0'),
    'seller detail': const SellerDetailScreen(sellerId: 'seller-1'),
    'search': const SearchScreen(),
    'inbox': const InboxScreen(),
    'chat detail': const ChatDetailScreen(sellerId: 'seller-1'),
    'jual': const JualScreen(),
    'add product': const AddProductScreen(),
    'profile setting': const ProfileSettingScreen(),
    'app setting': const AppSettingScreen(),
    'favorite': const FavoriteScreen(),
    'analytic': const AnalyticScreen(),
    'help desk': const HelpDeskScreen(),
    'contact support': const ContactSupportScreen(),
    'create ticket': const CreateTicketScreen(),
    'ticket detail': const TicketDetailScreen(ticketId: 'ticket-1'),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key} screen renders without layout errors', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2100);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: entry.value)),
      );
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

  testWidgets('home screen renders cards without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();

    expect(find.byType(ProductGrid), findsWidgets);
    expect(find.byKey(const Key('ai-fab')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('main layout renders its app bar assets', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: KosplyMainLayout())),
    );
    await tester.pump();

    expect(find.byType(KosplyMark), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    expect(find.byKey(const Key('top-bar-profile')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('top-bar-profile')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSettingScreen), findsOneWidget);
    expect(find.text('Nama'), findsOneWidget);
    Navigator.of(tester.element(find.byType(ProfileSettingScreen))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('Riwayat pencarian'), findsOneWidget);
    expect(find.text('Dibuka terakhir'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNothing);

    expect(find.text('Jual'), findsNothing);

    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();
    expect(find.byType(InboxScreen), findsOneWidget);
    expect(find.text('Cari username...'), findsOneWidget);
    expect(find.text('Belum dibaca'), findsOneWidget);
    expect(find.text('seller1'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(KosplyMark), findsOneWidget);
    expect(find.text('Setting'), findsOneWidget);

    await tester.tap(find.text('Penjual'));
    await tester.pumpAndSettle();
    expect(find.text('Jual'), findsOneWidget);

    await tester.tap(find.text('Jual'));
    await tester.pumpAndSettle();
    expect(find.byType(JualScreen), findsOneWidget);
    expect(find.text('Cari barang jualan...'), findsOneWidget);
  });

  testWidgets('settings screen renders without layout errors', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsScreen())),
    );
    await tester.pump();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
