/// @title Kosply App Entry
/// @notice Application entry point and route table.
/// @dev {KosplyMainLayout} stays as the nested home shell (Home, Search,
/// Jual, Inbox, Profil). The auth flow is exposed as named routes so each
/// screen can be opened independently during development.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'layouts/main_layout.dart';
import 'providers/theme_mode_provider.dart';
import 'screens/add_product_screen.dart';
import 'screens/app_setting_screen.dart';
import 'screens/analytic_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/contact_support_screen.dart';
import 'screens/create_ticket_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/help_desk_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/interest_screen.dart';
import 'screens/login_screen.dart';
import 'screens/product_view_screen.dart';
import 'screens/profile_setting_screen.dart';
import 'screens/register_email_screen.dart';
import 'screens/register_screen.dart';
import 'screens/see_all_screen.dart';
import 'screens/seller_detail_screen.dart';
import 'screens/setting_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/ticket_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/kosply_theme.dart';

/// @notice Starts the Flutter application.
/// @dev Wraps the app in a Riverpod {ProviderScope}.
/// @return void
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// @title MyApp
/// @notice Root widget of the Kosply app.
/// @dev Registers the named routes for the auth flow. Appearance follows
/// {themeModeProvider} so Settings can flip dark mode for the whole app.
class MyApp extends ConsumerWidget {
  /// @notice Creates the root widget.
  /// @param key Optional widget key.
  /// @return A new {MyApp} instance.
  const MyApp({super.key});

  /// @notice Builds the app shell and route table.
  /// @dev Entry point is temporarily {SplashScreen} while the flow is still
  /// under construction (onboarding still to come). The nested
  /// {KosplyMainLayout} is disabled as home and only reachable through the
  /// '/home' route.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The {MaterialApp} widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kosply',
      theme: KosplyTheme.light,
      darkTheme: KosplyTheme.dark,
      themeMode: themeMode,
      home: const SplashScreen(),
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        RegisterEmailScreen.routeName: (_) => const RegisterEmailScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
        InterestScreen.routeName: (_) => const InterestScreen(),
        KosplyMainLayout.routeName: (_) => const KosplyMainLayout(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        ProfileSettingScreen.routeName: (_) => const ProfileSettingScreen(),
        AppSettingScreen.routeName: (_) => const AppSettingScreen(),
        AddProductScreen.routeName: (_) => const AddProductScreen(),
        FavoriteScreen.routeName: (_) => const FavoriteScreen(),
        AnalyticScreen.routeName: (_) => const AnalyticScreen(),
        HelpDeskScreen.routeName: (_) => const HelpDeskScreen(),
        ContactSupportScreen.routeName: (_) => const ContactSupportScreen(),
        CreateTicketScreen.routeName: (_) => const CreateTicketScreen(),
      },
      // @dev Product view, see-all, and setting detail all need arguments, so
      // @dev they are generated instead of registered in the table above.
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case ProductViewScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) =>
                  ProductViewScreen(productId: settings.arguments! as String),
            );
          case SeeAllScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => settings.arguments! as SeeAllScreen,
            );
          case SettingDetailScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => settings.arguments! as SettingDetailScreen,
            );
          case SellerDetailScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) =>
                  SellerDetailScreen(sellerId: settings.arguments! as String),
            );
          case ChatDetailScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) =>
                  ChatDetailScreen(sellerId: settings.arguments! as String),
            );
          case TicketDetailScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) =>
                  TicketDetailScreen(ticketId: settings.arguments! as String),
            );
        }
        return null;
      },
    );
  }
}
