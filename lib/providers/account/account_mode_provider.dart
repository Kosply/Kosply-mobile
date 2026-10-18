/// @title Account mode provider
/// @notice Holds whether the student is shopping or selling.
/// @dev Persisted with SharedPreferences through {PreferencesStore}.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/keys/storage_keys.dart';
import '../../core/storage/providers/storage_providers.dart';
import '../../core/storage/stores/preferences_store.dart';
import '../../models/account/account_mode.dart';

/// @title AccountModeNotifier
/// @notice Mutates the active {AccountMode} and persists it.
class AccountModeNotifier extends Notifier<AccountMode> {
  /// @notice Restores the saved role, defaulting to buyer.
  /// @return The initial {AccountMode}.
  @override
  AccountMode build() {
    final PreferencesStore store = ref.watch(preferencesStoreProvider);
    final String? saved = store.readString(StorageKeys.accountMode);
    for (final AccountMode mode in AccountMode.values) {
      if (mode.name == saved) {
        return mode;
      }
    }
    return AccountMode.buyer;
  }

  /// @notice Sets the active role.
  /// @param mode Buyer or seller.
  /// @return void
  void setMode(AccountMode mode) {
    state = mode;
    unawaited(
      ref
          .read(preferencesStoreProvider)
          .writeString(StorageKeys.accountMode, mode.name),
    );
  }
}

/// @dev Global account-mode provider. Defaults to {AccountMode.buyer}.
final accountModeProvider = NotifierProvider<AccountModeNotifier, AccountMode>(
  AccountModeNotifier.new,
);
