/// @title FieldLabel
/// @notice Persistent label shown above a form field.
/// @dev Labels stay visible while the user types, unlike placeholders, so the
/// field never loses its meaning mid-form. Kept short — one to three words —
/// with any longer explanation in the help text under the field.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';

/// @title FieldLabel
/// @notice Reusable persistent field label.
class FieldLabel extends StatelessWidget {
  /// @notice Creates a field label.
  /// @param text Label text.
  /// @return A new {FieldLabel} instance.
  const FieldLabel(this.text, {super.key});

  /// @dev Label text.
  final String text;

  /// @notice Builds the field label.
  /// @param context The build context.
  /// @return The label widget.
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: KosplyColors.textPrimary,
      ),
    );
  }
}