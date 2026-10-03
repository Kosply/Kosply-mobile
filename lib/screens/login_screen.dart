/// @title LoginScreen
/// @notice Email login form.
/// @dev Built from the shared auth widgets: {AuthScaffold}, {AuthTextField},
/// and {FormActions}. Navigation is done through named routes.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../layouts/main_layout.dart';
import '../theme/kosply_colors.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/form_actions.dart';
import '../widgets/form_heading.dart';
import 'forgot_password_screen.dart';

/// @title LoginScreen
/// @notice Email login screen.
class LoginScreen extends StatefulWidget {
  /// @notice Creates the login screen.
  /// @param key Optional widget key.
  /// @return A new {LoginScreen} instance.
  const LoginScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/login';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Creates the mutable state.
  /// @return The {_LoginScreenState} instance.
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// @title _LoginScreenState
/// @notice Mutable state for {LoginScreen}.
/// @dev Holds the email and password controllers; no validation yet.
class _LoginScreenState extends State<LoginScreen> {
  /// @dev Email input controller.
  final TextEditingController _email = TextEditingController();

  /// @dev Password input controller.
  final TextEditingController _password = TextEditingController();

  /// @notice Releases both controllers.
  /// @return void
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// @notice Builds the login form.
  /// @dev Back pops the screen; the primary action lands on
  /// {KosplyMainLayout} until the real authentication is implemented.
  /// @param context The build context.
  /// @return The login screen widget.
  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FormHeading('Welcome back, student'),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _email,
            label: 'Email address',
            hint: 'name@kampus.ac.id',
            helper: 'Use the email you signed up with.',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _password,
            label: 'Password',
            hint: 'Your password',
            obscure: true,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Forgot password?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: KosplyColors.textSecondary),
                ),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ForgotPasswordScreen.routeName),
                  child: const Text(
                    'Reset password',
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
      bottomBar: FormActions(
        onBack: () => Navigator.of(context).pop(),
        onContinue: () => Navigator.of(
          context,
        ).pushReplacementNamed(KosplyMainLayout.routeName),
        backLabel: 'Go back',
        continueLabel: 'Sign in',
      ),
    );
  }
}