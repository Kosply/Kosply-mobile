/// @title SplashScreen
/// @notice Brand splash screen with automatic navigation.
/// @dev Static centered layout (icon, 10px gap, wordmark) plus a 2-second
/// timer that routes by session: home when signed in, the shortened Google
/// form when onboarding is pending, and Register otherwise.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../layouts/main_layout.dart';
import '../../../models/auth/auth_session.dart';
import '../../../providers/account/session_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/brand/kosply_wordmark.dart';
import '../register/register_email_screen.dart';
import '../register/register_screen.dart';

/// @title SplashScreen
/// @notice Splash screen widget with delayed navigation.
class SplashScreen extends ConsumerStatefulWidget {
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
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

/// @title _SplashScreenState
/// @notice Mutable state for {SplashScreen}.
/// @dev Starts a 2-second timer, then replaces itself with the session
/// destination.
class _SplashScreenState extends ConsumerState<SplashScreen> {
  /// @notice Starts the splash delay timer.
  /// @dev Guards navigation with {mounted}.
  /// @return void
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final AuthSession? session = ref.read(sessionProvider);
      final String target = switch (session) {
        null => RegisterScreen.routeName,
        AuthSession(onboardingRequired: true) =>
          RegisterEmailScreen.googleRouteName,
        _ => KosplyMainLayout.routeName,
      };
      Navigator.of(context).pushReplacementNamed(target);
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
            KosplyMark(size: 96),
            SizedBox(height: 10),
            KosplyWordmark(width: 160),
          ],
        ),
      ),
    );
  }
}
