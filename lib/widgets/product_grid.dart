/// @title ProductGrid
/// @notice Two-column catalogue grid that sizes cards by their own height.
/// @dev A [GridView] with the default child aspect ratio would force every cell
/// to be as tall as it is wide, which is shorter than a product card and
/// overflows by roughly 78px. [Wrap] with an explicit item width lets each card
/// keep its natural height, so nothing clips at any viewport width.
/// @author Kosply-mobile
library;

import 'package:flutter/widgets.dart';

import '../models/product.dart';
import 'product_card_tile.dart';

/// @title ProductGrid
/// @notice Responsive two-column grid of product cards.
class ProductGrid extends StatelessWidget {
  /// @notice Creates a product grid.
  /// @param items Products to render.
  /// @param spacing Gap between cards horizontally and vertically.
  /// @return A new {ProductGrid} instance.
  const ProductGrid({required this.items, this.spacing = 12, super.key});

  /// @dev Products to render.
  final List<Product> items;

  /// @dev Gap between cards horizontally and vertically.
  final double spacing;

  /// @notice Builds the grid.
  /// @param context The build context.
  /// @return The grid widget.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final Product item in items)
              SizedBox(
                width: width,
                child: ProductCardTile(product: item),
              ),
          ],
        );
      },
    );
  }
}
