/// @title RegisterScreen
/// @notice Registration landing screen.
/// @dev Layout keeps the approved design: top wordmark, centered illustration
/// block, and bottom-pinned actions. Reuses {SocialSignInButton},
/// {FormActions}, {KosplyWordmark}, and {KosplyColors}. Google sign-in stores
/// the session in {SecureStore} and opens the shortened registration form,
/// which skips email, password, and verification.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/account/session_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/auth/form/form_actions.dart';
import '../../../widgets/common/brand/kosply_wordmark.dart';
import '../../../widgets/auth/social/social_sign_in_button.dart';
import '../login/login_screen.dart';
import 'register_email_screen.dart';

/// @title RegisterScreen
/// @notice Registration screen widget.
class RegisterScreen extends ConsumerStatefulWidget {
  /// @notice Creates the register screen.
  /// @param key Optional widget key.
  /// @return A new {RegisterScreen} instance.
  const RegisterScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/register';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Creates the mutable state.
  /// @return The {_RegisterScreenState} instance.
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

/// @title _RegisterScreenState
/// @notice Mutable state for {RegisterScreen}.
/// @dev Guards the Google button against double taps while the session and
/// tokens are being written.
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  /// @dev True while the Google sign-in is running.
  bool _busy = false;

  /// @notice Opens the email login form.
  /// @param context The build context.
  /// @return Future completing when {LoginScreen} is popped.
  void _openLogin(BuildContext context) {
    Navigator.of(context).pushNamed(LoginScreen.routeName);
  }

  /// @notice Opens the step-by-step email registration form.
  /// @param context The build context.
  /// @return Future completing when {RegisterEmailScreen} is popped.
  void _openRegisterEmail(BuildContext context) {
    Navigator.of(context).pushNamed(RegisterEmailScreen.routeName);
  }

  /// @notice Signs in with Google and opens the shortened registration form.
  /// @dev The demo gateway stores the token pair in {SecureStore}; the real
  /// client id and backend exchange replace it later.
  /// @return Future completing when navigation starts.
  Future<void> _continueWithGoogle() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    await ref.read(sessionProvider.notifier).signInWithGoogle();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(
      RegisterEmailScreen.googleRouteName,
    );
  }

  /// @notice Builds the register screen.
  /// @dev Top wordmark fixed, middle centered, actions pinned at the bottom.
  /// @param context The build context.
  /// @return The register screen widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KosplyColors.card,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: KosplyWordmark(),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('assets/images/register_artwork.png'),
                        height: 260,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 10),
                      KosplyWordmark(width: 140),
                      SizedBox(height: 8),
                      Text(
                        'Buy and sell pre-loved stuff\nfrom students around you.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: KosplyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SocialSignInButton(
                    label: 'Continue with Google',
                    asset: 'assets/images/google.png',
                    onTap: () => _continueWithGoogle(),
                  ),
                  // SocialSignInButton(
                  //   label: 'Continue with Apple',
                  //   asset: 'assets/images/apple.png',
                  //   onTap: () => _openHome(context),
                  // ),
                  const SizedBox(height: 12),
                  const Text(
                    'or',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: KosplyColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: FormActions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () => _openRegisterEmail(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KosplyColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage('assets/images/logo.png'),
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Sign up with email',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(
                        child: Text(
                          'Already have an account? ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: KosplyColors.textSecondary),
                        ),
                      ),
                      Flexible(
                        child: GestureDetector(
                          onTap: () => _openLogin(context),
                          child: const Text(
                            'Sign in',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: KosplyColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
