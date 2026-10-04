/// @title AuthTextField
/// @notice Form field made of a persistent label, a card input, and a help
/// or error line underneath.
/// @dev Shared by every form in the app. Owns the label typography, the card
/// fill, the bottom-only border, the placeholder, and the helper / error
/// message, so the whole field reads the same everywhere. The error state
/// paints the border red and swaps the help text for a message that says what
/// to fix.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';
import 'field_label.dart';

/// @title AuthTextField
/// @notice Reusable labelled card input with help and error states.
class AuthTextField extends StatelessWidget {
  /// @notice Creates a labelled card input.
  /// @param controller Controller owning the text value.
  /// @param label Persistent label above the input; hidden when empty.
  /// @param hint Placeholder showing an example value.
  /// @param helper Help text under the card; hidden when empty.
  /// @param error Error message under the card; overrides [helper] and paints
  /// the border red.
  /// @param obscure Whether the text is obscured.
  /// @param keyboardType Optional keyboard type.
  /// @param onChanged Optional change callback.
  /// @param suffix Optional trailing widget inside the input.
  /// @return A new {AuthTextField} instance.
  const AuthTextField({
    required this.controller,
    this.label = '',
    this.hint = '',
    this.helper,
    this.error,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
    this.suffix,
    super.key,
  });

  /// @dev Controller owning the text value.
  final TextEditingController controller;

  /// @dev Persistent label above the input.
  final String label;

  /// @dev Placeholder showing an example value.
  final String hint;

  /// @dev Help text under the card.
  final String? helper;

  /// @dev Error message under the card.
  final String? error;

  /// @dev Whether the text is obscured.
  final bool obscure;

  /// @dev Optional keyboard type.
  final TextInputType? keyboardType;

  /// @dev Optional change callback.
  final ValueChanged<String>? onChanged;

  /// @dev Optional trailing widget inside the input.
  final Widget? suffix;

  /// @notice Builds the label, input card, and help or error line.
  /// @param context The build context.
  /// @return The form field widget.
  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    final supportText = hasError ? error : helper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          FieldLabel(label),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: KosplyColors.inputFill,
            border: Border(
              bottom: BorderSide(
                color: hasError
                    ? KosplyColors.error
                    : KosplyColors.inputBorder,
              ),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: KosplyColors.textSecondary),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        if ((supportText ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            supportText!,
            style: TextStyle(
              fontSize: 12,
              height: 1.3,
              color: hasError
                  ? KosplyColors.error
                  : KosplyColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}