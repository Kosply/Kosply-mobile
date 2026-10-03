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
}