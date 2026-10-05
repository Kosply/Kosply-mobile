/// @title FormStep
/// @notice Reusable descriptor for one step of a multi-step form.
/// @dev Shared by the registration form ({RegisterEmailScreen}) and the
/// password-reset flow ({ForgotPasswordScreen}) so both flows share the same
/// heading / label / placeholder / help text / validation structure.
///
/// Microcopy follows three rules used by consumer apps such as Gojek:
/// sentence case, conversational and encouraging headings, and helper or
/// error text that always says what to do next. Placeholders only show an
/// example format; the requirement itself lives in the persistent label and
/// the help text under the field.
/// @author Kosply-mobile
library;

import 'package:flutter/widgets.dart';

/// @title FormStep
/// @notice Static description of a single form step.
/// @dev Pure data holder: describes what to render and how to validate it.
class FormStep {
  /// @notice Creates a step descriptor.
  /// @param title Heading shown above the field.
  /// @param hint Placeholder showing an example value.
  /// @param helper Help text under the card explaining the requirement.
  /// @param validator Returns the error message, or null when valid.
  /// @param keyboardType Keyboard type for the input.
  /// @param obscure Whether the input text is obscured.
  /// @param isCodeStep Whether the step renders the boxed code inputs.
  /// @return A new {FormStep} instance.
  const FormStep({
    required this.title,
    required this.hint,
    required this.helper,
    required this.validator,
    this.keyboardType,
    this.obscure = false,
    this.isCodeStep = false,
  });

  /// @notice Builds the free-form email step shared by both flows.
  /// @return The email {FormStep}.
  FormStep.email()
    : title = "What's your email?",
      hint = 'name@kampus.ac.id',
      helper =
          'Any email works. We only use it to send your verification code.',
      validator = FormValidators.email(),
      keyboardType = TextInputType.emailAddress,
      obscure = false,
      isCodeStep = false;

  /// @notice Builds the email verification code step shared by both flows.
  /// @return The code {FormStep}.
  FormStep.code()
    : title = 'Check your inbox',
      hint = '',
      helper = 'The code expires in 10 minutes.',
      validator = FormValidators.code(),
      keyboardType = TextInputType.number,
      obscure = false,
      isCodeStep = true;

  /// @notice Builds a password step.
  /// @param title Heading shown above the field.
  /// @param helper Help text under the card.
  /// @return The password {FormStep}.
  FormStep.password({
    this.title = 'Lock it down',
    this.helper =
        'At least 6 characters. Mix in a number so nobody can guess it.',
  }) : hint = 'Something only you know',
       validator = FormValidators.password(),
       keyboardType = null,
       obscure = true,
       isCodeStep = false;

  /// @dev Heading shown above the field.
  final String title;

  /// @dev Placeholder showing an example value.
  final String hint;

  /// @dev Help text under the card explaining the requirement.
  final String helper;

  /// @dev Validator returning null when the value is valid.
  final String? Function(String value) validator;

  /// @dev Keyboard type for the input.
  final TextInputType? keyboardType;

  /// @dev Whether the input text is obscured.
  final bool obscure;

  /// @dev Whether the step renders the boxed code inputs instead of one input.
  final bool isCodeStep;
}

/// @title FormValidators
/// @notice Reusable validators shared by every form in the app.
/// @dev Each validator returns null when the value is valid, otherwise a short
/// message that names the problem and shows a valid example. Messages never
/// blame the user and stay around twelve words or fewer.
/// @author Kosply-mobile
class FormValidators {
  // @dev Prevents instantiation of this utility holder.
  const FormValidators._();

  /// @notice Accepts any email input, only rejecting an empty value.
  /// @param example Example address shown in the error message.
  /// @return A validator for the email field.
  static String? Function(String) email({String example = 'name@kampus.ac.id'}) {
    return (value) => value.trim().isEmpty
        ? 'Your email is empty. Try something like $example.'
        : null;
  }

  /// @notice Accepts letters, numbers, and spaces only.
  /// @param example Example value shown in the error message.
  /// @return A validator for a name-like field.
  static String? Function(String) letters({String example = 'Fajar Arrizki'}) {
    return (value) {
      final valid = RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value.trim());
      return valid && value.trim().isNotEmpty
          ? null
          : 'Use letters and numbers only, like $example.';
    };
  }

  /// @notice Accepts digits only.
  /// @param example Example value shown in the error message.
  /// @return A validator for a numeric field.
  static String? Function(String) number({
    String example = '253140701111034',
  }) {
    return (value) {
      final valid = RegExp(r'^\d+$').hasMatch(value.trim());
      return valid && value.trim().isNotEmpty
          ? null
          : 'Numbers only, like $example.';
    };
  }

  /// @notice Accepts letters, numbers, and punctuation used in campus names.
  /// @dev Campus and major names often carry digits and symbols, for example
  /// "Universitas Indonesia 45" or "S1 Teknik Informatika", so this
  /// validator is looser than [letters].
  /// @param example Example value shown in the error message.
  /// @return A validator for a university or study program field.
  static String? Function(String) campus({
    String example = 'Universitas Indonesia 45',
  }) {
    return (value) {
      final valid = RegExp(r"^[a-zA-Z0-9 .,&/'()-]+$").hasMatch(value.trim());
      return valid && value.trim().isNotEmpty
          ? null
          : 'Use the official name, like $example.';
    };
  }

  /// @notice Requires a password of at least [minLength] characters.
  /// @param minLength Minimum number of characters.
  /// @return A validator for a password field.
  static String? Function(String) password({int minLength = 6}) {
    return (value) => value.trim().length >= minLength
        ? null
        : 'Passwords need at least $minLength characters.';
  }

  /// @notice Requires a verification code of exactly [length] digits.
  /// @param length Number of digits in the code.
  /// @return A validator for the verification code step.
  static String? Function(String) code({int length = 4}) {
    final pattern = RegExp('^\\d{$length}\$');
    return (value) => pattern.hasMatch(value.trim())
        ? null
        : 'That code is not $length digits yet. Check and try again.';
  }
}