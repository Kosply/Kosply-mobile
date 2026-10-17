/// @title AccountRepository
/// @notice Offline-first access to the signed-in student's profile.
/// @dev The profile is the cached {Users} row marked with `isMe`; saves write
/// the same row through {AccountDao} so every listener updates at once.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../../core/database/daos/account_dao.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/cache_marker.dart';
import '../../models/account/user_profile.dart';
import '../shared/local_user.dart';

/// @title AccountRepository
/// @notice Reactive profile access for Settings and the profile form.
class AccountRepository {
  /// @notice Creates the repository.
  /// @param dao Drift access to the account cache.
  /// @return A new {AccountRepository} instance.
  AccountRepository({required this.dao});

  /// @dev Drift access to the account cache.
  final AccountDao dao;

  /// @notice Streams the saved profile.
  /// @return Stream of the profile, empty before the first save.
  Stream<UserProfile> watchProfile() {
    return dao.watchProfile().map(_toProfile);
  }

  /// @notice Replaces the saved profile.
  /// @param profile Fields to keep.
  /// @return Future completing when the write is durable.
  Future<void> saveProfile(UserProfile profile) {
    final int now = utcMillisNow();
    return dao.upsertProfile(
      UsersCompanion(
        id: const Value<String>(localUserId),
        name: Value<String>(profile.name),
        username: Value<String>(profile.username),
        bio: Value<String>(profile.bio),
        photo: Value<String>(profile.avatarPath),
        updatedAt: Value<int>(now),
        lastFetched: Value<int>(now),
      ),
    );
  }

  UserProfile _toProfile(UserRow? row) {
    if (row == null) {
      return const UserProfile();
    }
    return UserProfile(
      name: row.name,
      username: row.username,
      bio: row.bio,
      avatarPath: row.photo,
    );
  }
}
