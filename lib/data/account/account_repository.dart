/// @title AccountRepository
/// @notice The signed-in student's own profile: `GET/PATCH /api/users/me`.
/// @dev Reads stream from the cached `users` row flagged `isMe`, so the
/// avatar and name update everywhere the moment a write lands. Writes go to
/// the server first and the cache stores what the server answered, so the
/// app never shows a name the backend refused (e.g. `USERNAME_TAKEN`).
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../../core/database/daos/account_dao.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/cache_marker.dart';
import '../../core/network/api_client.dart';
import '../../core/network/json_read.dart';
import '../../models/account/user_profile.dart';

/// @title AccountRepository
/// @notice Profile reads from the cache and writes through the backend.
class AccountRepository {
  /// @notice Creates the repository.
  /// @param dao Drift access to the account cache.
  /// @param api Backend client.
  /// @return A new {AccountRepository} instance.
  AccountRepository({required this.dao, required this.api});

  /// @dev Drift access to the account cache.
  final AccountDao dao;

  /// @dev Backend client.
  final ApiClient api;

  /// @notice Streams the cached profile of the signed-in student.
  /// @return Stream of the profile, empty before the first sync.
  Stream<UserProfile> watchProfile() {
    return dao.watchProfile().map(_toProfile);
  }

  /// @notice Pulls `GET /api/users/me` into the cache.
  /// @return Future completing when the cache holds the server profile.
  Future<void> refreshMe() async {
    final Map<String, dynamic> json = await api.get('/api/users/me');
    await storeMe(json.object('item') ?? const <String, dynamic>{});
  }

  /// @notice Writes a server user object as the signed-in profile.
  /// @param user Backend user, e.g. the `user` of a login or `item` of /me.
  /// @return Future completing when the row is durable.
  Future<void> storeMe(Map<String, dynamic> user) async {
    final String id = user.str('id');
    if (id.isEmpty) {
      return;
    }
    final int now = utcMillisNow();
    await dao.upsertProfile(
      UsersCompanion(
        id: Value<String>(id),
        email: user.containsKey('email')
            ? Value<String>(user.str('email'))
            : const Value<String>.absent(),
        name: Value<String>(user.str('name')),
        username: Value<String>(user.str('username')),
        bio: Value<String>(user.str('bio')),
        photo: Value<String>(user.str('photo')),
        universitas: Value<String>(user.str('universitas')),
        programStudi: Value<String>(user.str('programStudi')),
        role: Value<String>(user.str('role').isEmpty ? 'BUYER' : user.str('role')),
        updatedAt: Value<int>(now),
        lastFetched: Value<int>(now),
      ),
    );
  }

  /// @notice Saves name, username, bio and photo through `PATCH /users/me`.
  /// @dev Only an `http(s)` photo is sent: the avatar column holds URLs, and
  /// a bundled asset path means "no photo of my own", which clears it.
  /// @param profile Edited profile.
  /// @return Future completing when the server accepted and the cache updated.
  Future<void> saveProfile(UserProfile profile) async {
    final String photo = profile.avatarPath;
    final bool remotePhoto =
        photo.startsWith('http://') || photo.startsWith('https://');
    final Map<String, dynamic> json = await api.patch(
      '/api/users/me',
      body: <String, Object?>{
        'name': profile.name,
        'username': profile.username,
        'bio': profile.bio.isEmpty ? null : profile.bio,
        'photo': remotePhoto ? photo : null,
      },
    );
    await storeMe(json.object('item') ?? const <String, dynamic>{});
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
