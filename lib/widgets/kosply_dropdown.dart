/// @title KosplyDropdown
/// @notice Outlined select used on Help desk and support tickets.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';

/// @title KosplyDropdown
/// @notice Single-select dropdown matching the search-pill outline.
class KosplyDropdown extends StatelessWidget {
  /// @notice Creates the dropdown.
  /// @param items Labels in display order.
  /// @param onChanged Called when a label is chosen.
  /// @param value Currently selected label; null shows [hint].
  /// @param hint Placeholder when nothing is selected.
  /// @return A new {KosplyDropdown} instance.
  const KosplyDropdown({
    required this.items,
    required this.onChanged,
    this.value,
    this.hint = 'Pilih masalah',
    super.key,
  });

  /// @dev Labels in display order.
  final List<String> items;

  /// @dev Called when a label is chosen.
  final ValueChanged<String> onChanged;

  /// @dev Currently selected label.
  final String? value;

  /// @dev Placeholder when nothing is selected.
  final String hint;

  /// @notice Builds the outlined dropdown.
  /// @param context The build context.
  /// @return The dropdown widget.
  @override
  Widget build(BuildContext context) {
    final String? selected = value != null && items.contains(value)
        ? value
        : null;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: KosplyColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KosplyColors.outlineOf(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selected,
          hint: Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: KosplyColors.textSecondaryOf(context),
            ),
          ),
          iconEnabledColor: KosplyColors.textSecondaryOf(context),
          dropdownColor: KosplyColors.surfaceOf(context),
          style: TextStyle(
            fontSize: 13,
            color: KosplyColors.textPrimaryOf(context),
          ),
          items: [
            for (final String item in items)
              DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (String? next) {
            if (next != null) {
              onChanged(next);
            }
          },
        ),
      ),
    );
  }
}
