/// @title ForgotPasswordScreen
/// @notice Password reset flow: email, email verification code, new password.
/// @dev Shares {SteppedForm} with the registration flow, so the UI and
/// validation behaviour are identical; finishing the last step replaces the
/// stack with {KosplyMainLayout}.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../layouts/main_layout.dart';
import '../models/form_step.dart';
import '../widgets/stepped_form.dart';

/// @title ForgotPasswordScreen
/// @notice Password reset flow entry point.
class ForgotPasswordScreen extends StatelessWidget {
  /// @notice Creates the forgot-password screen.
  /// @param key Optional widget key.
  /// @return A new {ForgotPasswordScreen} instance.
  const ForgotPasswordScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/forgot-password';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @dev The three steps, rendered one input per screen.
  static final List<FormStep> steps = [
    FormStep(
      title: 'Forgot your password?',
      hint: 'name@kampus.ac.id',
      helper: "We'll email you a code to reset it.",
      keyboardType: TextInputType.emailAddress,
      validator: FormValidators.email(),
    ),
    FormStep.code(),
    FormStep.password(
      title: 'Pick a new password',
      helper: 'At least 6 characters, and different from your last one.',
    ),
  ];

  /// @notice Builds the password reset form.
  /// @dev Finishes on {KosplyMainLayout}.
  /// @param context The build context.
  /// @return The forgot-password screen widget.
  @override
  Widget build(BuildContext context) {
    return SteppedForm(
      steps: steps,
      onCompleted: () => Navigator.of(
        context,
      ).pushReplacementNamed(KosplyMainLayout.routeName),
    );
  }
}