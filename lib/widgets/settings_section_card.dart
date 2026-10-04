/// @title SettingsSectionCard
/// @notice Grouped card that wraps the rows of one settings category.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';

/// @title SettingsSectionCard
/// @notice Outlined card for a list of {SettingsTile}s.
class SettingsSectionCard extends StatelessWidget {
  /// @notice Creates the section card.
  /// @param children Setting rows stacked inside the card.
  /// @return A new {SettingsSectionCard} instance.
  const SettingsSectionCard({required this.children, super.key});

  /// @dev Setting rows stacked inside the card.
  final List<Widget> children;

  /// @notice Builds the outlined card.
  /// @param context The build context.
  /// @return The card widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KosplyColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KosplyColors.outlineOf(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 66,
                color: KosplyColors.outlineOf(context),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
