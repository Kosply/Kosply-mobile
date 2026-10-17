/// @title Storage providers
/// @notice Exposes the reusable storage components to Riverpod consumers.
/// @dev The defaults are in-memory so widget tests need no overrides; the app
/// entry point overrides both with platform-backed instances.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stores/preferences_store.dart';
import '../stores/secure_store.dart';

/// @dev Small non-sensitive settings. Overridden in main with the
/// @dev SharedPreferences-backed store.
final preferencesStoreProvider = Provider<PreferencesStore>(
  (ref) => PreferencesStore.memory(),
);

/// @dev Tokens and credentials. Overridden in main with the keystore-backed
/// @dev store.
final secureStoreProvider = Provider<SecureStore>(
  (ref) => SecureStore.memory(),
);
