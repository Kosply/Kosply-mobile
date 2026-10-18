/// @title Profile provider
/// @notice Holds the signed-in student's editable profile.
/// @dev Backed by the Drift cache; saves write the `isMe` row through the
/// {AccountRepository} so every listener updates at once.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers/database_provider.dart';
import '../../data/account/account_repository.dart';
import '../../models/account/user_profile.dart';

/// @dev Profile repository backed by the Drift cache.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(dao: ref.watch(appDatabaseProvider).accountDao),
);

/// @dev The cached profile stream.
final profileStreamProvider = StreamProvider<UserProfile>(
  (ref) => ref.watch(accountRepositoryProvider).watchProfile(),
);

/// @title ProfileNotifier
/// @notice Mirrors the cached profile and forwards saves to the repository.
class ProfileNotifier extends Notifier<UserProfile> {
  /// @notice Follows the cached profile.
  /// @return The current profile, empty before the first save.
  @override
  UserProfile build() {
    return ref.watch(profileStreamProvider).value ?? const UserProfile();
  }

  /// @notice Replaces the saved profile.
  /// @param profile Fields to keep.
  /// @return void
  void save(UserProfile profile) {
    unawaited(ref.read(accountRepositoryProvider).saveProfile(profile));
  }
}

/// @dev Profile view of the cache, refreshed whenever the row changes.
final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
