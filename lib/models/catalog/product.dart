/// @title Product
/// @notice Catalogue entry rendered by [ProductCard] and [ProductViewScreen].
/// @dev Screens pass this around instead of loose strings. The fields come
/// from the backend cache. {placeholderImage} is only the artwork shown when
/// a listing has no photo yet.
/// @author Kosply-mobile
library;

/// @title Product
/// @notice A single catalogue item.
class Product {
  /// @notice Creates a catalogue item.
  /// @param id Stable identifier used to route to the detail screen.
  /// @param title Item name.
  /// @param price Formatted price label.
  /// @param location Short location label.
  /// @param imagePath Asset path of the item image.
  /// @param quantity Units still available.
  /// @param category Category label shown in the info rows.
  /// @param description Long description text.
  /// @param gallery Asset paths of the gallery thumbnails.
  /// @param sellerId Identifier of the student selling the item.
  /// @param sellerName Display name of the seller.
  /// @param sellerAvatarPath Asset path of the seller photo.
  /// @param sellerActiveLabel Relative activity line for the seller.
  /// @return A new {Product} instance.
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.imagePath,
    this.quantity = 1,
    this.category = 'Kategori',
    this.description = '',
    this.gallery = const <String>[],
    this.sellerId = '',
    this.sellerName = 'seller',
    this.sellerAvatarPath = '',
    this.sellerActiveLabel = '',
  });

  /// @dev Stable identifier used to route to the detail screen.
  final String id;

  /// @dev Item name.
  final String title;

  /// @dev Formatted price label.
  final String price;

  /// @dev Short location label.
  final String location;

  /// @dev Asset path of the item image.
  final String imagePath;

  /// @dev Units still available.
  final int quantity;

  /// @dev Category label shown in the info rows.
  final String category;

  /// @dev Long description text.
  final String description;

  /// @dev Asset paths of the gallery thumbnails.
  final List<String> gallery;

  /// @dev Identifier of the student selling the item.
  final String sellerId;

  /// @dev Display name of the seller.
  final String sellerName;

  /// @dev Asset path of the seller photo.
  final String sellerAvatarPath;

  /// @dev Relative activity line for the seller.
  final String sellerActiveLabel;

  /// @notice Numeric price parsed from [price], used to sort "Termurah".
  int get priceValue {
    final String digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  /// @dev Artwork shown when a listing has no photo.
  static const String placeholderImage =
      'assets/images/placeholder_catalog.png';
}
