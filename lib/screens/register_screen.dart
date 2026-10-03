/// @title RegisterScreen
/// @notice Registration landing screen.
/// @dev Layout keeps the approved design: top wordmark, centered illustration
/// block, and bottom-pinned actions. Reuses {SocialSignInButton},
/// {FormActions}, {KosplyWordmark}, and {KosplyColors}.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../layouts/main_layout.dart';
import '../theme/kosply_colors.dart';
import '../widgets/form_actions.dart';
import '../widgets/kosply_wordmark.dart';
import '../widgets/social_sign_in_button.dart';
import 'login_screen.dart';
import 'register_email_screen.dart';

/// @title RegisterScreen
/// @notice Registration screen widget.
class RegisterScreen extends StatelessWidget {
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

  /// @notice Opens the nested home shell.
  /// @dev Placeholder destination for the social sign-in buttons and the
  /// "Already have an account? Sign in" link until the auth flow is wired.
  /// @param context The build context.
  /// @return Future completing when the shell is popped.
  void _openHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(KosplyMainLayout.routeName);
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
                        image: AssetImage(
                          'assets/images/register_artwork.png',
                        ),
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
                    onTap: () => _openHome(context),
                  ),
                  const SizedBox(height: 12),
                  SocialSignInButton(
                    label: 'Continue with Apple',
                    asset: 'assets/images/apple.png',
                    onTap: () => _openHome(context),
                  ),
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
                          style: TextStyle(
                            color: KosplyColors.textSecondary,
                          ),
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