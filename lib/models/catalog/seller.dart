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

  /// @notice Builds a placeholder seller.
  /// @param index Zero-based seller slot, wrapped across [count].
  /// @return A placeholder {Seller}.
  factory Seller.placeholder(int index) {
    final int slot = index % count;
    return Seller(
      id: 'seller-${slot + 1}',
      name: 'seller${slot + 1}',
      avatarPath: avatar,
      activeLabel: 'aktif ${(slot * 11) + 5} menit lalu',
      bio: loremIpsum,
    );
  }

  /// @dev Number of placeholder sellers.
  static const int count = 4;

  /// @dev Shared profile photo.
  static const String avatar = 'assets/images/profile_placeholder.png';

  /// @dev Placeholder bio used on the seller screen.
  static const String loremIpsum =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut '
      'enim ad minim veniam, quis nostrud exercitation ullamco laboris '
      'nisi ut aliquip ex ea commodo consequat.';
}
