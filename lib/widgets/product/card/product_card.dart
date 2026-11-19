/// @title ProductCard
/// @notice Catalogue card: image, location, title, and price.
/// @dev Title and location stay on one line so two-column rows keep the same
/// height on Home and seller detail.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../../../theme/colors/kosply_colors.dart';
import '../../common/icons/phosphor_icons.dart';
import '../../common/images/kosply_image.dart';

/// @title ProductCard
/// @notice Tappable catalogue card shell.
class ProductCard extends StatelessWidget {
  /// @notice Creates a product card.
  /// @param title Item name.
  /// @param price Formatted price label.
  /// @param location Short location label.
  /// @param imagePath Asset path of the item image.
  /// @param onTap Optional tap handler.
  /// @param highlighted Whether the AI just pointed at this card.
  /// @return A new {ProductCard} instance.
  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.location,
    required this.imagePath,
    this.onTap,
    this.highlighted = false,
  });

  /// @dev Item name.
  final String title;

  /// @dev Formatted price label.
  final String price;

  /// @dev Short location label.
  final String location;

  /// @dev Asset path of the item image.
  final String imagePath;

  /// @dev Optional tap handler.
  final VoidCallback? onTap;

  /// @dev Whether the AI just pointed at this card.
  final bool highlighted;

  /// @notice Builds the card.
  /// @param context The build context.
  /// @return The card widget.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: KosplyColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted
                ? KosplyColors.primary
                : KosplyColors.outlineOf(context),
            width: highlighted ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: KosplyImage(imagePath),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const PhosphorGlyph(
                  PhosphorCode.mapPin,
                  size: 12,
                  color: KosplyColors.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: KosplyColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: KosplyColors.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: KosplyColors.textPrimaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
