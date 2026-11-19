/// @title Seller
/// @notice Campus seller profile shown on product detail and seller detail.
/// @author Kosply-mobile
library;

/// @title Seller
/// @notice One student selling pre-loved kos items.
class Seller {
  /// @notice Creates a seller profile.
  /// @param id Stable identifier used to route to the seller screen.
  /// @param name Username shown on the identity row.
  /// @param avatarPath Asset path of the profile photo.
  /// @param activeLabel Relative activity line, e.g. "aktif 5 menit lalu".
  /// @param bio Short campus bio under the identity row.
  /// @return A new {Seller} instance.
  const Seller({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.activeLabel,
    required this.bio,
  });

  /// @dev Stable identifier used to route to the seller screen.
  final String id;

  /// @dev Username shown on the identity row.
  final String name;

  /// @dev Asset path of the profile photo.
  final String avatarPath;

  /// @dev Relative activity line.
  final String activeLabel;

  /// @dev Short campus bio.
  final String bio;

  /// @dev Photo shown when a profile has none of its own.
  static const String avatar = 'assets/images/profile_placeholder.png';
}
