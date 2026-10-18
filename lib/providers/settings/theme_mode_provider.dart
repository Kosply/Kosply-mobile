/// @title Theme mode provider
/// @notice Holds light / dark appearance for the marketplace.
/// @dev Persisted with SharedPreferences through {PreferencesStore}.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/keys/storage_keys.dart';
import '../../core/storage/providers/storage_providers.dart';
import '../../core/storage/stores/preferences_store.dart';

/// @title ThemeModeNotifier
/// @notice Mutates the app {ThemeMode} and persists it.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  /// @notice Restores the saved mode, defaulting to light.
  /// @return The initial {ThemeMode}.
  @override
  ThemeMode build() {
    final PreferencesStore store = ref.watch(preferencesStoreProvider);
    return store.readBool(StorageKeys.themeDark) == true
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  /// @notice Turns dark mode on or off.
  /// @param isDark True to use {ThemeMode.dark}.
  /// @return void
  void setDark(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    unawaited(
      ref
          .read(preferencesStoreProvider)
          .writeBool(StorageKeys.themeDark, isDark),
    );
  }
}

/// @dev Global theme-mode provider. Defaults to {ThemeMode.light}.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
