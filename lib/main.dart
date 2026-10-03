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
import 'screens/forgot_password_screen.dart';
import 'screens/interest_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_email_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

/// @notice Starts the Flutter application.
/// @dev Wraps the app in a Riverpod {ProviderScope}.
/// @return void
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// @title MyApp
/// @notice Root widget of the Kosply app.
/// @dev Registers the named routes for the auth flow.
class MyApp extends StatelessWidget {
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
  /// @return The {MaterialApp} widget.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kosply',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        RegisterEmailScreen.routeName: (_) => const RegisterEmailScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
        InterestScreen.routeName: (_) => const InterestScreen(),
        KosplyMainLayout.routeName: (_) => const KosplyMainLayout(),
      },
    );
  }
}