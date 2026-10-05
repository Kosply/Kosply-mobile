/// @title SettingDetailScreen
/// @notice Lightweight destination opened from a settings row.
/// @dev Holds the title, icon and copy until the matching feature is built.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../theme/kosply_colors.dart';
import '../widgets/phosphor_icons.dart';

/// @title SettingDetailScreen
/// @notice Placeholder feature screen opened from Settings.
class SettingDetailScreen extends StatelessWidget {
  /// @notice Creates the destination screen.
  /// @param title Feature name shown in the app bar and body.
  /// @param description Supporting copy for the empty state.
  /// @param icon Phosphor code point for the empty-state badge.
  /// @return A new {SettingDetailScreen} instance.
  const SettingDetailScreen({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  /// @dev Named route for this screen.
  static const routeName = '/setting-detail';

  /// @dev Feature name.
  final String title;

  /// @dev Supporting copy.
  final String description;

  /// @dev Phosphor code point.
  final int icon;

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @param title Feature name.
  /// @param description Supporting copy.
  /// @param icon Phosphor code point.
  /// @return Future completing when the screen is popped.
  static Future<void> push(
    BuildContext context, {
    required String title,
    required String description,
    required int icon,
  }) {
    return Navigator.of(context).pushNamed(
      routeName,
      arguments: SettingDetailScreen(
        title: title,
        description: description,
        icon: icon,
      ),
    );
  }

  /// @notice Builds the empty-state destination.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        leading: IconButton(
          icon: PhosphorGlyph(
            PhosphorCode.arrowLeft,
            size: 20,
            color: KosplyColors.textPrimaryOf(context),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: KosplyColors.textPrimaryOf(context),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: KosplyColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: PhosphorGlyph(
                  icon,
                  size: 28,
                  color: KosplyColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: KosplyColors.textPrimaryOf(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: KosplyColors.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
