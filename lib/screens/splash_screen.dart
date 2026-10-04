/// @title SplashScreen
/// @notice Brand splash screen with automatic navigation to Register.
/// @dev Static centered layout (icon, 10px gap, wordmark) plus a 2-second
/// timer that routes to {RegisterScreen} via named route.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';
import '../widgets/kosply_wordmark.dart';
import 'register_screen.dart';

/// @title SplashScreen
/// @notice Splash screen widget with delayed navigation.
class SplashScreen extends StatefulWidget {
  /// @notice Creates the splash screen.
  /// @param key Optional widget key.
  /// @return A new {SplashScreen} instance.
  const SplashScreen({super.key});

  /// @dev Named route for this screen.
  /// @dev Not "/" because that is reserved by {Navigator.defaultRouteName}.
  static const routeName = '/splash';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Creates the mutable state.
  /// @return The {_SplashScreenState} instance.
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// @title _SplashScreenState
/// @notice Mutable state for {SplashScreen}.
/// @dev Starts a 2-second timer, then replaces itself with Register.
class _SplashScreenState extends State<SplashScreen> {
  /// @notice Starts the splash delay timer.
  /// @dev Guards navigation with {mounted}.
  /// @return void
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(RegisterScreen.routeName);
    });
  }

  /// @notice Builds the centered logo composition.
  /// @dev Icon 96x96, gap 10, wordmark width 160.
  /// @param context The build context.
  /// @return The splash screen widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KosplyColors.card,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Image(
              image: AssetImage('assets/images/logo.png'),
              width: 96,
              height: 96,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            KosplyWordmark(width: 160),
          ],
        ),
      ),
    );
  }
}