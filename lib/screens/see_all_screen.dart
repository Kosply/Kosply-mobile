/// @title SeeAllScreen
/// @notice "Lihat semua" catalogue screen opened from a home section heading.
/// @dev Shows the section title in the app bar with a back arrow that pops to
/// the previous screen, and lays the catalogue out as a padded two-column grid.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/kosply_colors.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/product_grid.dart';

/// @title SeeAllScreen
/// @notice Full catalogue listing for one home section.
class SeeAllScreen extends StatelessWidget {
  /// @notice Creates the see-all screen.
  /// @param title Section title shown in the app bar.
  /// @param items Catalogue entries to list.
  /// @return A new {SeeAllScreen} instance.
  const SeeAllScreen({required this.title, required this.items, super.key});

  /// @dev Named route for this screen.
  static const routeName = '/see-all';

  /// @dev Section title shown in the app bar.
  final String title;

  /// @dev Catalogue entries to list.
  final List<Product> items;

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @param title Section title to show.
  /// @param items Catalogue entries to list.
  /// @return Future completing when the screen is popped.
  static Future<void> push(
    BuildContext context, {
    required String title,
    required List<Product> items,
  }) {
    return Navigator.of(context).pushNamed(
      routeName,
      arguments: SeeAllScreen(title: title, items: items),
    );
  }

  /// @notice Builds the catalogue grid.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [ProductGrid(items: items)],
      ),
    );
  }
}
