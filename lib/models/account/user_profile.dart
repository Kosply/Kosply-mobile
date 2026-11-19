/// @title UserProfile
/// @notice Signed-in student profile edited on Profile setting.
/// @author Kosply-mobile
library;

/// @title UserProfile
/// @notice Display name, username, bio, and optional photo path.
class UserProfile {
  /// @notice Creates a profile.
  /// @param name Display name.
  /// @param username Handle shown on the marketplace.
  /// @param bio Seller bio; unused in pembeli mode.
  /// @param avatarPath Asset path of the profile photo; empty when unset.
  /// @param universitas Campus collected during onboarding.
  /// @param programStudi Study programme collected during onboarding.
  /// @return A new {UserProfile} instance.
  const UserProfile({
    this.name = '',
    this.username = '',
    this.bio = '',
    this.avatarPath = '',
    this.universitas = '',
    this.programStudi = '',
  });

  /// @dev Display name.
  final String name;

  /// @dev Handle shown on the marketplace.
  final String username;

  /// @dev Seller bio.
  final String bio;

  /// @dev Asset path of the profile photo; empty when unset.
  final String avatarPath;

  /// @dev Campus collected during onboarding.
  final String universitas;

  /// @dev Study programme collected during onboarding.
  final String programStudi;

  /// @notice Whether a photo has been added.
  bool get hasPhoto => avatarPath.isNotEmpty;

  /// @notice Copies this profile with selected fields replaced.
  /// @return A new {UserProfile}.
  UserProfile copyWith({
    String? name,
    String? username,
    String? bio,
    String? avatarPath,
    String? universitas,
    String? programStudi,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarPath: avatarPath ?? this.avatarPath,
      universitas: universitas ?? this.universitas,
      programStudi: programStudi ?? this.programStudi,
    );
  }
}
