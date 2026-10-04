/// @title ProductCardTile
/// @notice Binds a [Product] to [ProductCard] and opens the detail screen.
/// @dev Keeps the field-by-field mapping and the navigation call in one place,
/// so lists only pass a [Product] and every card opens the same route.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/product_view_screen.dart';
import 'product_card.dart';

/// @title ProductCardTile
/// @notice Tappable catalogue card driven by a [Product].
class ProductCardTile extends StatelessWidget {
  /// @notice Creates a tappable card.
  /// @param product Product to render.
  /// @return A new {ProductCardTile} instance.
  const ProductCardTile({required this.product, super.key});

  /// @dev Product to render.
  final Product product;

  /// @notice Builds the card.
  /// @param context The build context.
  /// @return The card widget.
  @override
  Widget build(BuildContext context) {
    return ProductCard(
      title: product.title,
      price: product.price,
      location: product.location,
      imagePath: product.imagePath,
      onTap: () => ProductViewScreen.push(context, product.id),
    );
  }
}
