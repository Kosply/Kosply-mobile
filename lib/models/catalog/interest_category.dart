/// @title InterestCategory
/// @notice Data for one interest category card in the home personalization.
/// @dev Pure data holder: icon path, title, and a short description.
/// @author Kosply-mobile
library;

/// @title InterestCategory
/// @notice One selectable interest category.
/// @dev Pure data holder used by {InterestCategoryCard}.
class InterestCategory {
  /// @notice Creates a category descriptor.
  /// @param title Category name shown under the icon.
  /// @param description Short one-line description.
  /// @param icon Asset path of the category icon.
  /// @return A new {InterestCategory} instance.
  const InterestCategory({
    required this.title,
    required this.description,
    required this.icon,
  });

  /// @dev Category name.
  final String title;

  /// @dev Short description.
  final String description;

  /// @dev Icon asset path.
  final String icon;
}

/// @title KosplyCategories
/// @notice The nine interest categories offered during personalization.
/// @dev Kept in one place so the grid and any future copy stay in sync.
class KosplyCategories {
  // @dev Prevents instantiation of this utility holder.
  const KosplyCategories._();

  /// @dev Default category list shown on the personalization screen.
  static const List<InterestCategory> all = [
    InterestCategory(
      title: 'Belajar',
      description: 'Buku & alat tulis',
      icon: 'assets/images/categories/belajar.png',
    ),
    InterestCategory(
      title: 'Cuci Setrika',
      description: 'Laundry & setrika',
      icon: 'assets/images/categories/cuci_setrika.png',
    ),
    InterestCategory(
      title: 'Dapur Kos',
      description: 'Peralatan dapur',
      icon: 'assets/images/categories/dapur-kos.png',
    ),
    InterestCategory(
      title: 'Elektronik',
      description: 'Kabel & charger',
      icon: 'assets/images/categories/electronik.png',
    ),
    InterestCategory(
      title: 'Kamar',
      description: 'Perabot kamar',
      icon: 'assets/images/categories/kamar.png',
    ),
    InterestCategory(
      title: 'Mandi',
      description: 'Perlengkapan mandi',
      icon: 'assets/images/categories/mandi.png',
    ),
    InterestCategory(
      title: 'Pindahan',
      description: 'Kardus & furnitur',
      icon: 'assets/images/categories/pindahan.png',
    ),
    InterestCategory(
      title: 'Hobi',
      description: 'Alat & perlengkapan',
      icon: 'assets/images/categories/hobi.png',
    ),
    InterestCategory(
      title: 'Fashion',
      description: 'Pakaian & aksesoris',
      icon: 'assets/images/categories/fassion.png',
    ),
  ];
}