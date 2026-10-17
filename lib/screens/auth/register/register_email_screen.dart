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

import '../../../models/auth/auth_session.dart';
import '../../../models/form/form_step.dart';
import '../../../providers/account/session_provider.dart';
import '../../../widgets/auth/form/stepped_form.dart';
import '../onboarding/interest_screen.dart';

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

  /// @notice Validates the collected values, stores the session, and moves on
  /// to {InterestScreen}.
  /// @dev The student number, campus, and major are validated but not cached
  /// yet; the users table gains those columns when the backend fetch lands.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @param values One value per rendered step.
  /// @return Future completing when navigation starts.
  Future<void> _finish(
    BuildContext context,
    WidgetRef ref,
    List<String> values,
  ) async {
    final SessionNotifier session = ref.read(sessionProvider.notifier);
    if (googleFlow) {
      await session.completeRegistration(
        name: values[0].trim(),
        username: values[1].trim(),
      );
    } else {
      await session.signInWithEmail(email: values[0].trim());
      await session.completeRegistration(
        name: values[1].trim(),
        username: values[2].trim(),
      );
    }
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(InterestScreen.routeName);
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
      onCompleted: (List<String> values) =>
          unawaited(_finish(context, ref, values)),
    );
  }
}
