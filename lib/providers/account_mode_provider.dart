/// @title Account mode provider
/// @notice Holds whether the student is shopping or selling.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_mode.dart';

/// @title AccountModeNotifier
/// @notice Mutates the active {AccountMode}.
class AccountModeNotifier extends Notifier<AccountMode> {
  /// @notice Starts in buyer mode, the default shopping role.
  /// @return The initial {AccountMode}.
  @override
  AccountMode build() => AccountMode.buyer;

  /// @notice Sets the active role.
  /// @param mode Buyer or seller.
  /// @return void
  void setMode(AccountMode mode) {
    state = mode;
  }
}

/// @dev Global account-mode provider. Defaults to {AccountMode.buyer}.
final accountModeProvider = NotifierProvider<AccountModeNotifier, AccountMode>(
  AccountModeNotifier.new,
);
