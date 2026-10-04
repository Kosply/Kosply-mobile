/// @title TintedIconButton
/// @notice Square primary action used beside catalogue search fields.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';
import 'phosphor_icons.dart';

/// @title TintedIconButton
/// @notice 48px control tinted like the settings icon badge.
class TintedIconButton extends StatelessWidget {
  /// @notice Creates the tinted control.
  /// @param codePoint Phosphor glyph to draw.
  /// @param onPressed Tap handler.
  /// @return A new {TintedIconButton} instance.
  const TintedIconButton({
    required this.codePoint,
    required this.onPressed,
    super.key,
  });

  /// @dev Phosphor glyph to draw.
  final int codePoint;

  /// @dev Tap handler.
  final VoidCallback onPressed;

  /// @notice Builds the 48px tinted square.
  /// @param context The build context.
  /// @return The button widget.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: KosplyColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: PhosphorGlyph(
              codePoint,
              size: 20,
              color: KosplyColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
