/// @title AccountMode
/// @notice Buyer or seller role used across the student marketplace.
/// @dev Settings, and later selling tools, read this so a student can shop
/// and list pre-loved kos items without creating two logins.
/// @author Kosply-mobile
library;

/// @title AccountMode
/// @notice Active marketplace role.
enum AccountMode {
  /// @dev Student shopping for pre-loved kos items.
  buyer,

  /// @dev Student listing items for other students to buy.
  seller,
}
