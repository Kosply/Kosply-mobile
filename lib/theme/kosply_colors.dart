/// @title KosplyColors
/// @notice Single source of truth for the Kosply colour palette.
/// @dev Replaces the `static const primary` that used to be duplicated in
/// every screen, so the brand colour is changed in one place only.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

/// @title KosplyColors
/// @notice Brand and neutral colours used across the app.
class KosplyColors {
  // @dev Prevents instantiation of this utility holder.
  const KosplyColors._();

  /// @dev Brand purple used for primary actions and links.
  static const Color primary = Color(0xFF4F46E5);

  /// @dev Online / last-active indicator green.
  static const Color active = Color(0xFF16A34A);

  /// @dev Muted text colour for helper and secondary lines.
  static const Color textSecondary = Color(0x8A000000);

  /// @dev Neutral card background.
  static const Color card = Colors.white;

  /// @dev Input surface: same as the page background, so only the underline
  /// @dev is visible. Fields stay flat instead of looking like grey cards.
  static const Color inputFill = Colors.white;

  /// @dev Underline colour of the inputs.
  static const Color inputBorder = Color(0xFFD0D0D0);

  /// @dev Neutral outline colour for outlined buttons and cards.
  static const Color outline = Color(0xFFD0D0D0);

  /// @dev Strong text colour.
  static const Color textPrimary = Color(0xFF1D1B20);

  /// @dev Error message colour.
  static const Color error = Colors.red;

  /// @dev Dark scaffold background.
  static const Color darkBackground = Color(0xFF121212);

  /// @dev Dark card / surface colour.
  static const Color darkSurface = Color(0xFF1C1B1F);

  /// @dev Dark primary text.
  static const Color darkTextPrimary = Color(0xFFE6E1E5);

  /// @dev Dark secondary text.
  static const Color darkTextSecondary = Color(0x99FFFFFF);

  /// @dev Dark outline / divider.
  static const Color darkOutline = Color(0xFF49454F);

  /// @notice Whether the current theme is dark.
  /// @param context The build context.
  /// @return True when {Theme.brightness} is dark.
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// @notice Page background for the active appearance.
  static Color backgroundOf(BuildContext context) {
    return isDark(context) ? darkBackground : card;
  }

  /// @notice Card surface for the active appearance.
  static Color surfaceOf(BuildContext context) {
    return isDark(context) ? darkSurface : card;
  }

  /// @notice Strong text for the active appearance.
  static Color textPrimaryOf(BuildContext context) {
    return isDark(context) ? darkTextPrimary : textPrimary;
  }

  /// @notice Secondary text for the active appearance.
  static Color textSecondaryOf(BuildContext context) {
    return isDark(context) ? darkTextSecondary : textSecondary;
  }

  /// @notice Outline for the active appearance.
  static Color outlineOf(BuildContext context) {
    return isDark(context) ? darkOutline : outline;
  }
}
