/// @title SplashScreen
/// @notice Brand splash screen with automatic navigation.
/// @dev Static centered layout (icon, 10px gap, wordmark). Location and
/// notification permission are asked here, then a 2-second timer routes by
/// session: home when signed in, the shortened Google form when onboarding
/// is pending, and Register otherwise.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../layouts/main_layout.dart';
import '../../../models/auth/auth_session.dart';
import '../../../providers/account/session_provider.dart';
import '../../../providers/startup/startup_permissions.dart';
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
/// @dev Asks for location and notifications, waits out the brand delay, then
/// replaces itself with the session destination. Navigation waits for the
/// dialogs so Home does not ask for location a second time.
class _SplashScreenState extends ConsumerState<SplashScreen> {
  /// @notice Starts the permission pass and the splash delay.
  /// @dev Guards navigation with {mounted}.
  /// @return void
  @override
  void initState() {
    super.initState();
    unawaited(_leave());
  }

  /// @notice Leaves the splash after permissions and the brand delay.
  /// @return Future completing when the next route is up, or when this
  /// screen was disposed first.
  Future<void> _leave() async {
    await Future.wait<void>(<Future<void>>[
      ref.read(startupPermissionsProvider).ask(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) {
      return;
    }
    final AuthSession? session = ref.read(sessionProvider);
    final String target = switch (session) {
      null => RegisterScreen.routeName,
      AuthSession(onboardingRequired: true) =>
        RegisterEmailScreen.googleRouteName,
      _ => KosplyMainLayout.routeName,
    };
    Navigator.of(context).pushReplacementNamed(target);
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
