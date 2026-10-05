/// @title FilterChipBar
/// @notice Horizontal pill filters used on the seller catalogue.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';

/// @title FilterChipBar
/// @notice Scrollable row of selectable filter pills.
class FilterChipBar extends StatelessWidget {
  /// @notice Creates the chip bar.
  /// @param labels Filter labels in display order.
  /// @param selected Currently selected label.
  /// @param onSelected Called when a chip is tapped.
  /// @return A new {FilterChipBar} instance.
  const FilterChipBar({
    required this.labels,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// @dev Filter labels in display order.
  final List<String> labels;

  /// @dev Currently selected label.
  final String selected;

  /// @dev Called when a chip is tapped.
  final ValueChanged<String> onSelected;

  /// @notice Builds the chip row.
  /// @param context The build context.
  /// @return The chip bar widget.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < labels.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _Chip(
                label: labels[i],
                selected: labels[i] == selected,
                onTap: () => onSelected(labels[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// @title _Chip
/// @notice One filter pill.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? KosplyColors.primary
              : KosplyColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? KosplyColors.primary
                : KosplyColors.outlineOf(context),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : KosplyColors.textPrimaryOf(context),
          ),
        ),
      ),
    );
  }
}
