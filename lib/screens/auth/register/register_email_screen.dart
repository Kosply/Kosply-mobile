/// @title RegisterEmailScreen
/// @notice Step-by-step registration: email, name, username, password,
/// email verification, NIM, university, study program.
/// @dev All behaviour lives in {SteppedForm}; this screen only declares the
/// step list and where to go after the last step. The Google flow reuses the
/// same form with the email, password, and verification steps removed, since
/// the Google account already carries the verified email.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../models/auth/auth_session.dart';
import '../../../models/form/form_step.dart';
import '../../../providers/account/session_provider.dart';
import '../../../providers/sync/app_sync_provider.dart';
import '../../../widgets/auth/form/stepped_form.dart';
import '../onboarding/interest_screen.dart';
import 'register_screen.dart';

/// @title RegisterEmailScreen
/// @notice Registration flow entry point.
class RegisterEmailScreen extends ConsumerWidget {
  /// @notice Creates the registration form screen.
  /// @param googleFlow When true, skips email, password, and verification.
  /// @param key Optional widget key.
  /// @return A new {RegisterEmailScreen} instance.
  const RegisterEmailScreen({this.googleFlow = false, super.key});

  /// @dev Named route for this screen.
  static const routeName = '/register-email';

  /// @dev Named route of the Google variant.
  static const googleRouteName = '/register-google';

  /// @dev Index of the email step in {steps}.
  static const int emailStep = 0;

  /// @dev Index of the password step. Continuing here mails the code.
  static const int passwordStep = 3;

  /// @dev Index of the inbox step.
  static const int codeStep = 4;

  /// @dev Google flow flag.
  final bool googleFlow;

  /// @dev The eight steps, rendered one input per screen.
  /// @dev Not const: validators are built with an example message per step.
  static final List<FormStep> steps = [
    FormStep.email(),
    FormStep(
      title: "What's your name?",
      hint: 'Fajar Arrizki',
      helper: 'Use the name printed on your student card.',
      validator: FormValidators.letters(),
    ),
    FormStep(
      title: 'Pick a username',
      hint: 'fajar.arrizki',
      helper: 'This is what other students will see.',
      validator: FormValidators.letters(example: 'fajar.arrizki'),
    ),
    FormStep.password(),
    FormStep.code(),
    FormStep(
      title: 'Your student number',
      hint: '253140701111034',
      helper: 'Digits only, straight from your campus portal.',
      keyboardType: TextInputType.number,
      validator: FormValidators.number(),
    ),
    FormStep(
      title: 'Where do you study?',
      hint: 'Universitas Indonesia 45',
      helper: 'Copy it exactly as your campus writes it.',
      validator: FormValidators.campus(),
    ),
    FormStep(
      title: "What's your major?",
      hint: 'S1 Teknik Informatika',
      helper: 'Numbers and symbols like . and - are fine.',
      validator: FormValidators.campus(example: 'S1 Teknik Informatika'),
    ),
  ];

  /// @dev Google variant: name, username, NIM, university, and major only.
  static final List<FormStep> googleSteps = [
    steps[1],
    steps[2],
    steps[5],
    steps[6],
    steps[7],
  ];

  /// @notice Mails the code, checks it, then creates the account.
  /// @dev The password step calls `POST /api/auth/email-code`. The inbox step
  /// calls `POST /api/auth/email-code/verify` and leaves the code live. The
  /// last step is `POST /api/auth/register` with that code. The Google variant
  /// skips the mailbox and completes the shell account with
  /// `PATCH /api/users/me`. A taken email or username sends the form back to
  /// that step. The student number is validated here but stored later, with
  /// the seller verification (`POST /api/verifications`).
  /// @param ref Riverpod handle.
  /// @param step Index of the submitted step.
  /// @param values One value per rendered step.
  /// @return Null to continue, or feedback to stay on a step.
  Future<StepFeedback?> _submit(
    WidgetRef ref,
    int step,
    List<String> values,
  ) async {
    final int last = (googleFlow ? googleSteps : steps).length - 1;
    final SessionNotifier session = ref.read(sessionProvider.notifier);
    final int usernameStep = googleFlow ? 1 : 2;
    final String email = values[emailStep].trim();
    try {
      if (!googleFlow && step == passwordStep) {
        await session.requestEmailCode(email);
      } else if (!googleFlow && step == codeStep) {
        await session.verifyEmailCode(email: email, code: values[codeStep]);
      } else if (step == last) {
        if (googleFlow) {
          await session.completeRegistration(
            name: values[0].trim(),
            username: values[1].trim(),
            universitas: values[3].trim(),
            programStudi: values[4].trim(),
          );
        } else {
          await session.register(
            email: email,
            name: values[1].trim(),
            username: values[2].trim(),
            password: values[passwordStep],
            universitas: values[6].trim(),
            programStudi: values[7].trim(),
            code: values[codeStep],
          );
        }
        await ref.read(appSyncProvider).syncAccount();
      }
    } on ApiException catch (error) {
      switch (error.code) {
        case 'EMAIL_TAKEN':
          return StepFeedback(error.userMessage, step: emailStep);
        case 'USERNAME_TAKEN':
          return StepFeedback(error.userMessage, step: usernameStep);
        case 'EMAIL_CODE_INVALID':
          return StepFeedback(error.userMessage, step: codeStep);
        default:
          return StepFeedback(error.userMessage);
      }
    }
    return null;
  }

  /// @notice Mails another registration code.
  /// @param ref Riverpod handle.
  /// @param email Address shown on the inbox step.
  /// @return Null when the new code is on its way, or feedback to show.
  Future<StepFeedback?> _resend(WidgetRef ref, String email) async {
    try {
      await ref.read(sessionProvider.notifier).requestEmailCode(email.trim());
    } on ApiException catch (error) {
      if (error.code == 'EMAIL_TAKEN') {
        return StepFeedback(error.userMessage, step: emailStep);
      }
      return StepFeedback(error.userMessage);
    }
    return null;
  }

  /// @notice Moves on to {InterestScreen} once the account exists.
  /// @param context The build context.
  /// @return void
  void _finish(BuildContext context) {
    // @dev Drops the auth screens so Back from here never returns to them.
    Navigator.of(context).pushNamedAndRemoveUntil(
      InterestScreen.routeName,
      (Route<dynamic> route) => false,
    );
  }

  /// @notice Leaves the Google variant from its first step.
  /// @dev The Google form replaces whatever opened it (the register screen or
  /// the splash), so popping would leave an empty navigator. Instead the
  /// half-finished Google session is cleared and {RegisterScreen} reopens.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return Future completing when navigation starts.
  Future<void> _cancelGoogle(BuildContext context, WidgetRef ref) async {
    await ref.read(sessionProvider.notifier).signOut();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(RegisterScreen.routeName);
  }

  /// @notice Builds the registration form.
  /// @dev Finishes on {InterestScreen} to personalize the home feed.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The registration screen widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthSession? session = ref.watch(sessionProvider);
    final bool prefillName =
        googleFlow &&
        session != null &&
        session.displayName.isNotEmpty;

    return SteppedForm(
      steps: googleFlow ? googleSteps : steps,
      initialValues: prefillName
          ? <int, String>{0: session.displayName}
          : const <int, String>{},
      onStepSubmit: (int step, List<String> values) =>
          _submit(ref, step, values),
      onResend: googleFlow ? null : (String email) => _resend(ref, email),
      onCompleted: (List<String> values) => _finish(context),
      onExit: googleFlow ? () => unawaited(_cancelGoogle(context, ref)) : null,
    );
  }
}
