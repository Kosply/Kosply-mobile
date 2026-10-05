/// @title Profile provider
/// @notice Holds the signed-in student's editable profile.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';

/// @title ProfileNotifier
/// @notice Mutates the in-memory {UserProfile}.
class ProfileNotifier extends Notifier<UserProfile> {
  /// @notice Starts with an empty profile.
  /// @return The initial {UserProfile}.
  @override
  UserProfile build() => const UserProfile();

  /// @notice Replaces the saved profile.
  /// @param profile Fields to keep.
  /// @return void
  void save(UserProfile profile) {
    state = profile;
  }
}

/// @dev Session-scoped profile. Empty until Profile setting is saved.
final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
