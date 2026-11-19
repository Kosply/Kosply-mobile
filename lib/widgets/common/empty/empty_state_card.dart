/// @title Empty state card
/// @notice Welcome-shaped card with an icon and one line of copy.
/// @dev No button. Used when a list has nothing to show yet.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../../../theme/colors/kosply_colors.dart';
import '../icons/phosphor_icons.dart';

/// @title EmptyStateCard
/// @notice Centered icon in a circle plus a short explanation.
class EmptyStateCard extends StatelessWidget {
  /// @notice Creates the card.
  /// @param icon Phosphor code point drawn in the circle.
  /// @param message Explanation under the icon.
  /// @return A new {EmptyStateCard} instance.
  const EmptyStateCard({required this.icon, required this.message, super.key});

  /// @dev Phosphor code point drawn in the circle.
  final int icon;

  /// @dev Explanation under the icon.
  final String message;

  /// @notice Builds the card.
  /// @param context The build context.
  /// @return The card.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(
        color: KosplyColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KosplyColors.outlineOf(context)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: KosplyColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: PhosphorGlyph(icon, size: 28, color: KosplyColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: KosplyColors.textPrimaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
