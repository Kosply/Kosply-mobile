/// @title KosplySearchbar
/// @notice Compact search pill aligned with the catalogue cards.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../../../theme/colors/kosply_colors.dart';

/// @title KosplySearchbar
/// @notice Marketplace search field used on Home, Search, and Inbox.
class KosplySearchbar extends StatelessWidget {
  /// @notice Creates the search pill.
  /// @param hint Placeholder shown inside the pill.
  /// @param showFilter Whether to show the trailing filter icon.
  /// @param onChanged Called when the field text changes; when set, the pill
  /// becomes an editable {TextField}.
  /// @param onSubmitted Called when the student submits the field.
  /// @param onFilter Called when the filter icon is tapped.
  /// @param controller Optional text controller for the editable field.
  /// @return A new {KosplySearchbar} instance.
  const KosplySearchbar({
    this.hint = 'Cari meja belajar, kipas, rice cooker...',
    this.showFilter = true,
    this.onChanged,
    this.onSubmitted,
    this.onFilter,
    this.controller,
    this.focusNode,
    super.key,
  });

  /// @dev Placeholder shown inside the pill.
  final String hint;

  /// @dev Whether to show the trailing filter icon.
  final bool showFilter;

  /// @dev Called when the field text changes.
  final ValueChanged<String>? onChanged;

  /// @dev Called when the student submits the field.
  final ValueChanged<String>? onSubmitted;

  /// @dev Called when the filter icon is tapped.
  final VoidCallback? onFilter;

  /// @dev Optional text controller for the editable field.
  final TextEditingController? controller;

  /// @dev Optional focus node so the AI can focus this field.
  final FocusNode? focusNode;

  /// @notice Builds the search pill.
  /// @param context The build context.
  /// @return The search widget.
  @override
  Widget build(BuildContext context) {
    final bool editable =
        onChanged != null || controller != null || focusNode != null;
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
                    focusNode: focusNode,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    textInputAction: onSubmitted == null
                        ? TextInputAction.done
                        : TextInputAction.search,
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
            InkWell(
              key: const Key('search-filter'),
              onTap: onFilter,
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.tune, size: 20, color: KosplyColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
