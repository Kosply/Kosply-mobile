/// @title Product
/// @notice Catalogue entry rendered by [ProductCard] and [ProductViewScreen].
/// @dev Exists so screens pass structured data around instead of loose
/// strings; still backed by placeholder values until the API lands.
/// @author Kosply-mobile
library;

import 'seller.dart';

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

  /// @notice Builds a catalogue item with the placeholder artwork.
  /// @param index Position used to vary the placeholder price and id.
  /// @return A placeholder {Product}.
  factory Product.placeholder(int index) {
    const List<String> prices = <String>[
      'Rp.375.000',
      'Rp.1.250.000',
      'Rp.80.000',
      'Rp.2.400.000',
      'Rp.150.000',
      'Rp.650.000',
      'Rp.990.000',
      'Rp.45.000',
      'Rp.3.100.000',
      'Rp.220.000',
      'Rp.780.000',
      'Rp.1.875.000',
      'Rp.175.000',
      'Rp.55.000',
      'Rp.90.000',
      'Rp.320.000',
    ];
    final Seller seller = Seller.placeholder(index);
    return Product(
      id: 'product-$index',
      title: titles[index % titles.length],
      price: prices[index % prices.length],
      location: 'Dekat gedung a',
      imagePath: placeholderImage,
      quantity: index % 3 + 1,
      category: categories[index % categories.length],
      description: loremIpsum,
      gallery: List<String>.filled(5, placeholderImage, growable: false),
      sellerId: seller.id,
      sellerName: seller.name,
      sellerAvatarPath: seller.avatarPath,
      sellerActiveLabel: seller.activeLabel,
    );
  }

  /// @dev Shared seller avatar path.
  static const String sellerAvatar = 'assets/images/profile_placeholder.png';

  /// @dev Shared placeholder artwork path.
  static const String placeholderImage =
      'assets/images/placeholder_catalog.png';

  /// @dev Placeholder item names for a campus second-hand catalogue.
  static const List<String> titles = <String>[
    'Meja belajar lipat',
    'Kipas angin meja',
    'Rice cooker 1.8L',
    'Kasur busa single',
    'Lampu belajar LED',
    'Rak sepatu 4 susun',
    'Dispenser galon',
    'Jemuran baju lipat',
    'Speaker bluetooth',
    'Setrika uap',
    'Panci stainless',
    'Kursi lipat kampus',
    'Bantal guling',
    'Galon air 19L',
    'Gorden jendela kos',
    'Karpet lantai 2x1',
  ];

  /// @dev Placeholder category labels.
  static const List<String> categories = <String>[
    'Kamar',
    'Dapur Kos',
    'Elektronik',
    'Belajar',
    'Hobi',
    'Pindahan',
  ];

  /// @dev Placeholder long description.
  static const String loremIpsum =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do '
      'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut '
      'enim ad minim veniam, quis nostrud exercitation ullamco laboris '
      'nisi ut aliquip ex ea commodo consequat.';
}
