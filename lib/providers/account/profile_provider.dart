/// @title Profile provider
/// @notice The signed-in student's profile for the app bar, settings and Jual.
/// @dev Streams the cached `users` row flagged `isMe`; {ProfileNotifier.save}
/// writes through `PATCH /api/users/me` and the cache follows the server.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers/database_provider.dart';
import '../../data/account/account_repository.dart';
import '../../models/account/user_profile.dart';
import '../network/api_provider.dart';

/// @dev Profile cache plus the `/api/users/me` calls.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(
    dao: ref.watch(appDatabaseProvider).accountDao,
    api: ref.watch(apiClientProvider),
  ),
);

/// @dev Cached profile stream.
final profileStreamProvider = StreamProvider<UserProfile>(
  (ref) => ref.watch(accountRepositoryProvider).watchProfile(),
);

/// @title ProfileNotifier
/// @notice Latest profile value plus the save action.
class ProfileNotifier extends Notifier<UserProfile> {
  /// @notice Mirrors the cached profile.
  /// @return The profile, empty before the first sync.
  @override
  UserProfile build() {
    return ref.watch(profileStreamProvider).value ?? const UserProfile();
  }

  /// @notice Saves the edited profile through the backend.
  /// @dev Throws {ApiException} when the server refuses, e.g. a taken
  /// username, so the settings screen can keep the form open and explain.
  /// @param profile Edited profile.
  /// @return Future completing when the server accepted it.
  Future<void> save(UserProfile profile) {
    return ref.read(accountRepositoryProvider).saveProfile(profile);
  }
}

/// @dev Global profile provider.
final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(
  ProfileNotifier.new,
);
