/// @title KosplySearchbar
/// @notice Compact search pill aligned with the catalogue cards.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';

/// @title KosplySearchbar
/// @notice Marketplace search field used on Home, Search, and Inbox.
class KosplySearchbar extends StatelessWidget {
  /// @notice Creates the search pill.
  /// @param hint Placeholder shown inside the pill.
  /// @param showFilter Whether to show the trailing filter icon.
  /// @param onChanged Called when the field text changes; when set, the pill
  /// becomes an editable {TextField}.
  /// @param controller Optional text controller for the editable field.
  /// @return A new {KosplySearchbar} instance.
  const KosplySearchbar({
    this.hint = 'Cari meja belajar, kipas, rice cooker...',
    this.showFilter = true,
    this.onChanged,
    this.controller,
    super.key,
  });

  /// @dev Placeholder shown inside the pill.
  final String hint;

  /// @dev Whether to show the trailing filter icon.
  final bool showFilter;

  /// @dev Called when the field text changes.
  final ValueChanged<String>? onChanged;

  /// @dev Optional text controller for the editable field.
  final TextEditingController? controller;

  /// @notice Builds the search pill.
  /// @param context The build context.
  /// @return The search widget.
  @override
  Widget build(BuildContext context) {
    final bool editable = onChanged != null || controller != null;
    final Color hintColor = KosplyColors.textSecondaryOf(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: KosplyColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KosplyColors.outlineOf(context)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: KosplyColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: editable
                ? TextField(
                    controller: controller,
                    onChanged: onChanged,
                    cursorColor: KosplyColors.primary,
                    style: TextStyle(
                      fontSize: 13,
                      color: KosplyColors.textPrimaryOf(context),
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: hint,
                      hintStyle: TextStyle(fontSize: 13, color: hintColor),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: hintColor),
                  ),
          ),
          if (showFilter) ...[
            const SizedBox(width: 8),
            const Icon(Icons.tune, size: 20, color: KosplyColors.primary),
          ],
        ],
      ),
    );
  }
}
