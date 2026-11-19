/// @title ForgotPasswordScreen
/// @notice Password reset flow: email, email verification code, new password.
/// @dev Shares {SteppedForm} with the registration flow. The email step asks
/// `POST /api/auth/forgot-password` to mail a code. The code step checks it
/// with `POST /api/auth/reset-code/check`. The last step calls
/// `reset-password`, signs in with the new password, then replaces the stack
/// with {KosplyMainLayout}.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../layouts/main_layout.dart';
import '../../../models/form/form_step.dart';
import '../../../providers/account/session_provider.dart';
import '../../../providers/sync/app_sync_provider.dart';
import '../../../widgets/auth/form/stepped_form.dart';

/// @title ForgotPasswordScreen
/// @notice Password reset flow entry point.
class ForgotPasswordScreen extends ConsumerWidget {
  /// @notice Creates the forgot-password screen.
  /// @param key Optional widget key.
  /// @return A new {ForgotPasswordScreen} instance.
  const ForgotPasswordScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/forgot-password';

  /// @dev Index of the email step.
  static const int emailStep = 0;

  /// @dev Index of the code step.
  static const int codeStep = 1;

  /// @dev Index of the new-password step.
  static const int passwordStep = 2;

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
      helper: 'At least 8 characters, and different from your last one.',
      minLength: 8,
    ),
  ];

  /// @notice Mails the code, checks it, then sets the new password.
  /// @dev The server answers the email step the same way for every address
  /// (no account enumeration). The code arrives in the inbox. A wrong or
  /// expired code sends the form back to the code step.
  /// @param ref Riverpod handle.
  /// @param step Index of the submitted step.
  /// @param values One value per step.
  /// @return Null to continue, or feedback to stay on a step.
  Future<StepFeedback?> _submit(
    WidgetRef ref,
    int step,
    List<String> values,
  ) async {
    final SessionNotifier session = ref.read(sessionProvider.notifier);
    final String email = values[emailStep].trim();
    try {
      if (step == emailStep) {
        await session.requestPasswordReset(email);
      } else if (step == codeStep) {
        await session.checkResetCode(email: email, code: values[codeStep]);
      } else if (step == passwordStep) {
        await session.resetPassword(
          email: email,
          code: values[codeStep],
          newPassword: values[passwordStep],
        );
        await ref.read(appSyncProvider).syncAccount();
      }
    } on ApiException catch (error) {
      if (error.code == 'RESET_INVALID') {
        return StepFeedback(error.userMessage, step: codeStep);
      }
      return StepFeedback(error.userMessage);
    }
    return null;
  }

  /// @notice Mails another reset code.
  /// @param ref Riverpod handle.
  /// @param email Address shown on the inbox step.
  /// @return Null when the new code is on its way, or feedback to show.
  Future<StepFeedback?> _resend(WidgetRef ref, String email) async {
    try {
      await ref.read(sessionProvider.notifier).requestPasswordReset(email.trim());
    } on ApiException catch (error) {
      return StepFeedback(error.userMessage);
    }
    return null;
  }

  /// @notice Builds the password reset form.
  /// @dev Finishes on {KosplyMainLayout}, signed in with the new password.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The forgot-password screen widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SteppedForm(
      steps: steps,
      onStepSubmit: (int step, List<String> values) =>
          _submit(ref, step, values),
      onResend: (String email) => _resend(ref, email),
      // @dev Drops login and register too, so Back from home cannot reach
      // @dev them.
      onCompleted: (List<String> values) => Navigator.of(context)
          .pushNamedAndRemoveUntil(
            KosplyMainLayout.routeName,
            (Route<dynamic> route) => false,
          ),
    );
  }
}
