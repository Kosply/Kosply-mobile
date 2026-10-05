/// @title SettingsTile
/// @notice One settings row: icon, title, description, trailing control.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';
import 'phosphor_icons.dart';

/// @title SettingsTile
/// @notice Reusable settings row used inside a section card.
class SettingsTile extends StatelessWidget {
  /// @notice Creates a settings row.
  /// @param icon Phosphor code point drawn in the leading badge.
  /// @param title Row heading.
  /// @param description One-line explanation under the title.
  /// @param onTap Optional tap handler; omitted for in-place controls.
  /// @param trailing Optional widget on the far side, such as a switch.
  /// @return A new {SettingsTile} instance.
  const SettingsTile({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.trailing,
    super.key,
  });

  /// @dev Phosphor code point.
  final int icon;

  /// @dev Row heading.
  final String title;

  /// @dev One-line explanation.
  final String description;

  /// @dev Optional tap handler.
  final VoidCallback? onTap;

  /// @dev Optional trailing widget.
  final Widget? trailing;

  /// @notice Builds the row.
  /// @param context The build context.
  /// @return The row widget.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: KosplyColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: PhosphorGlyph(
                  icon,
                  size: 20,
                  color: KosplyColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KosplyColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: KosplyColors.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                PhosphorGlyph(
                  PhosphorCode.caretRight,
                  size: 16,
                  color: KosplyColors.textSecondaryOf(context),
                ),
          ],
        ),
      ),
    );
  }
}
