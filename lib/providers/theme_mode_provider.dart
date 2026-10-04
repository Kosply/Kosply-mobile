/// @title Theme mode provider
/// @notice Holds light / dark appearance for the marketplace.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// @title ThemeModeNotifier
/// @notice Mutates the app {ThemeMode}.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  /// @notice Starts in light mode.
  /// @return The initial {ThemeMode}.
  @override
  ThemeMode build() => ThemeMode.light;

  /// @notice Turns dark mode on or off.
  /// @param isDark True to use {ThemeMode.dark}.
  /// @return void
  void setDark(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

/// @dev Global theme-mode provider. Defaults to {ThemeMode.light}.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
