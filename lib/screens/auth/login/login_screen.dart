/// @title LoginScreen
/// @notice Email login form.
/// @dev Built from the shared auth widgets: {AuthScaffold}, {AuthTextField},
/// and {FormActions}. Signing in stores the session and tokens through
/// {SecureStore} and lands on the home shell.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../layouts/main_layout.dart';
import '../../../models/form/form_step.dart';
import '../../../providers/account/session_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/auth/scaffold/auth_scaffold.dart';
import '../../../widgets/auth/fields/auth_text_field.dart';
import '../../../widgets/auth/form/form_actions.dart';
import '../../../widgets/auth/form/form_heading.dart';
import '../forgot_password/forgot_password_screen.dart';

/// @title LoginScreen
/// @notice Email login screen.
class LoginScreen extends ConsumerStatefulWidget {
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
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// @title _LoginScreenState
/// @notice Mutable state for {LoginScreen}.
/// @dev Holds the email and password controllers and their error messages.
class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// @dev Email input controller.
  final TextEditingController _email = TextEditingController();

  /// @dev Password input controller.
  final TextEditingController _password = TextEditingController();

  /// @dev Validation error of the email field.
  String? _emailError;

  /// @dev Validation error of the password field.
  String? _passwordError;

  /// @notice Releases both controllers.
  /// @return void
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// @notice Validates both fields, stores the session, and opens home.
  /// @dev The password is only checked locally for now; the backend verifies
  /// it once `/auth` is wired, and it is never persisted on device.
  /// @return Future completing when navigation starts.
  Future<void> _signIn() async {
    final String? emailError = FormValidators.email()(_email.text);
    final String? passwordError = FormValidators.password()(_password.text);
    if (emailError != null || passwordError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
      });
      return;
    }
    await ref
        .read(sessionProvider.notifier)
        .signInWithEmail(email: _email.text.trim());
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(KosplyMainLayout.routeName);
  }

  /// @notice Builds the login form.
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
            error: _emailError,
            onChanged: (_) {
              if (_emailError != null) {
                setState(() => _emailError = null);
              }
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _password,
            label: 'Password',
            hint: 'Your password',
            obscure: true,
            error: _passwordError,
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
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
                  onTap: () =>
                      Navigator.of(context)
                          .pushNamed(ForgotPasswordScreen.routeName),
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
        onContinue: _signIn,
        backLabel: 'Go back',
        continueLabel: 'Sign in',
      ),
    );
  }
}
