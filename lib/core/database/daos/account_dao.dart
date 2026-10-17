/// @title Account DAO
/// @notice Local reads and writes for the signed-in student's profile.
/// @dev The profile is the cached {Users} row marked with `isMe`.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/account_tables.dart';

part 'account_dao.g.dart';

/// @title AccountDao
/// @notice Reactive access to the persisted profile.
@DriftAccessor(tables: [Users])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  /// @notice Creates the DAO.
  /// @param db Owning database.
  /// @return A new {AccountDao} instance.
  AccountDao(super.db);

  /// @notice Streams the stored profile.
  /// @return Stream of the profile row, or null before the first save.
  Stream<UserRow?> watchProfile() {
    return (select(users)..where(($UsersTable row) => row.isMe.equals(true)))
        .watchSingleOrNull();
  }

  /// @notice Reads the stored profile once.
  /// @return Future resolving to the profile row, or null.
  Future<UserRow?> profileOnce() {
    return (select(users)..where(($UsersTable row) => row.isMe.equals(true)))
        .getSingleOrNull();
  }

  /// @notice Inserts or updates the single profile row.
  /// @param row Profile companion; `isMe` is pinned to true here.
  /// @return Future completing when the write is durable.
  Future<void> upsertProfile(UsersCompanion row) {
    return transaction(() async {
      await (update(users)..where(($UsersTable row) => row.isMe.equals(true)))
          .write(const UsersCompanion(isMe: Value<bool>(false)));
      await into(users).insertOnConflictUpdate(
        row.copyWith(isMe: const Value<bool>(true)),
      );
    });
  }
}
