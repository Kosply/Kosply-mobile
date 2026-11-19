/// @title Product form fill
/// @notice The approved listing text waiting for the add-product form.
/// @dev The AI preview does not write the controllers. Setujui stores one
/// fill here, and the form applies it when it is open.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// @title ProductFormFill
/// @notice One approved set of seller fields.
class ProductFormFill {
  /// @notice Creates a fill.
  /// @param title Item name.
  /// @param price Integer rupiah.
  /// @param description Sales text.
  /// @param category Category name, matched to the dropdown later.
  /// @param token Changes on every write, so a repeat of the same text applies.
  /// @return A new {ProductFormFill} instance.
  const ProductFormFill({
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.token,
  });

  /// @dev Item name.
  final String title;

  /// @dev Integer rupiah.
  final int price;

  /// @dev Sales text.
  final String description;

  /// @dev Category name.
  final String category;

  /// @dev Monotonic id of this write.
  final int token;
}

/// @title ProductFormFillNotifier
/// @notice Holds the latest approved fill.
class ProductFormFillNotifier extends Notifier<ProductFormFill?> {
  int _token = 0;

  /// @notice Starts empty. Nothing is written until Setujui.
  /// @return null.
  @override
  ProductFormFill? build() => null;

  /// @notice Stores the fields Setujui accepted.
  /// @param title Item name.
  /// @param price Integer rupiah.
  /// @param description Sales text.
  /// @param category Category name.
  /// @return void
  void write({
    required String title,
    required int price,
    required String description,
    required String category,
  }) {
    _token += 1;
    state = ProductFormFill(
      title: title,
      price: price,
      description: description,
      category: category,
      token: _token,
    );
  }
}

/// @dev Latest approved form fill. Null until Setujui.
final NotifierProvider<ProductFormFillNotifier, ProductFormFill?>
productFormFillProvider =
    NotifierProvider<ProductFormFillNotifier, ProductFormFill?>(
      ProductFormFillNotifier.new,
    );

/// @title AddProductPresence
/// @notice Mutable flag for the open add-product route.
/// @dev A field write does not notify listeners, so the form can set it from
/// initState and dispose without scheduling a frame.
class AddProductPresence {
  /// @dev True while the form route is mounted.
  bool mounted = false;
}

/// @dev Shared flag. The form sets [AddProductPresence.mounted].
final Provider<AddProductPresence> addProductPresenceProvider =
    Provider<AddProductPresence>((Ref ref) => AddProductPresence());
