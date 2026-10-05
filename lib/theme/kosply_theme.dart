/// @title KosplyTheme
/// @notice Light and dark {ThemeData} for the marketplace shell.
/// @dev Seeded from {KosplyColors.primary} so Material widgets follow the
/// brand purple in both appearances. Screen-level colours still come from
/// {KosplyColors} helpers that read {Theme.brightness}.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import 'kosply_colors.dart';

/// @title KosplyTheme
/// @notice App-wide light and dark themes.
class KosplyTheme {
  const KosplyTheme._();

  /// @notice Light appearance used as the default.
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: KosplyColors.primary,
        primary: KosplyColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: KosplyColors.card,
      appBarTheme: const AppBarTheme(
        backgroundColor: KosplyColors.card,
        foregroundColor: KosplyColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  /// @notice Dark appearance toggled from Settings.
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: KosplyColors.primary,
        primary: KosplyColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: KosplyColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: KosplyColors.darkSurface,
        foregroundColor: KosplyColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
