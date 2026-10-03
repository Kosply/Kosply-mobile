/// @title InterestCategoryCard
/// @notice Selectable interest card showing icon, title and description.
/// @dev White card, radius 12, grey border; content is left aligned. Selected
/// state paints the border and the title in the brand colour.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../models/interest_category.dart';
import '../theme/kosply_colors.dart';

/// @title InterestCategoryCard
/// @notice Reusable grid card for one interest category.
class InterestCategoryCard extends StatelessWidget {
  /// @notice Creates an interest card.
  /// @param category Category data to render.
  /// @param selected Whether the card is currently selected.
  /// @param onTap Tap callback.
  /// @return A new {InterestCategoryCard} instance.
  const InterestCategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// @dev Category data to render.
  final InterestCategory category;

  /// @dev Whether the card is currently selected.
  final bool selected;

  /// @dev Tap callback.
  final VoidCallback onTap;

  /// @notice Builds the category card.
  /// @param context The build context.
  /// @return The card widget.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: KosplyColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? KosplyColors.primary
                : KosplyColors.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(
              image: AssetImage(category.icon),
              width: 26,
              height: 26,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              category.title,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? KosplyColors.primary
                    : KosplyColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              category.description,
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: KosplyColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}