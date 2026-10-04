/// @title RegisterEmailScreen
/// @notice Step-by-step email registration: email, name, username, password,
/// email verification, NIM, university, study program.
/// @dev All behaviour lives in {SteppedForm}; this screen only declares the
/// step list and where to go after the last step.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../models/form_step.dart';
import '../widgets/stepped_form.dart';
import 'interest_screen.dart';

/// @title RegisterEmailScreen
/// @notice Registration flow entry point.
class RegisterEmailScreen extends StatelessWidget {
  /// @notice Creates the registration form screen.
  /// @param key Optional widget key.
  /// @return A new {RegisterEmailScreen} instance.
  const RegisterEmailScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/register-email';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

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

  /// @notice Builds the registration form.
  /// @dev Finishes on {InterestScreen} to personalize the home feed.
  /// @param context The build context.
  /// @return The registration screen widget.
  @override
  Widget build(BuildContext context) {
    return SteppedForm(
      steps: steps,
      onCompleted: () =>
          Navigator.of(context).pushReplacementNamed(InterestScreen.routeName),
    );
  }
}