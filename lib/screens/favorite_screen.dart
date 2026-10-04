/// @title FavoriteScreen
/// @notice Saved catalogue items, filled from the product-detail heart.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/placeholder_catalog.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../theme/kosply_colors.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/product_grid.dart';
import '../widgets/searchbar.dart';

/// @title FavoriteScreen
/// @notice Favorite destination opened from Settings.
class FavoriteScreen extends ConsumerStatefulWidget {
  /// @notice Creates the favorite screen.
  /// @return A new {FavoriteScreen} instance.
  const FavoriteScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/favorite';

  /// @dev Chip that lists every saved item.
  static const String filterAll = 'Semua';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Creates the mutable search and chip state.
  /// @return The {_FavoriteScreenState} instance.
  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

/// @title _FavoriteScreenState
/// @notice Holds the favorite query and selected category chip.
class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {
  String _query = '';
  String _filter = FavoriteScreen.filterAll;

  /// @notice Resolves saved ids into catalogue products, dropping unknowns.
  /// @param ids Favorite product ids.
  /// @return Matching catalogue items in id order.
  List<Product> _saved(Set<String> ids) {
    final List<Product> items = <Product>[];
    for (final String id in ids) {
      final Product product = PlaceholderCatalog.byId(id);
      if (product.id == id) {
        items.add(product);
      }
    }
    return items;
  }

  /// @notice Labels for the chip bar: Semua plus categories present in [items].
  /// @param items Currently saved products.
  /// @return Chip labels in display order.
  List<String> _chipLabels(List<Product> items) {
    final List<String> labels = <String>[FavoriteScreen.filterAll];
    for (final Product item in items) {
      if (!labels.contains(item.category)) {
        labels.add(item.category);
      }
    }
    return labels;
  }

  /// @notice Applies search and the selected chip to [items].
  /// @param items Currently saved products.
  /// @param filter Active category chip.
  /// @return The filtered list.
  List<Product> _visible(List<Product> items, String filter) {
    final String needle = _query.trim().toLowerCase();
    List<Product> result = items;
    if (needle.isNotEmpty) {
      result = result
          .where((Product item) => item.title.toLowerCase().contains(needle))
          .toList();
    }
    if (filter != FavoriteScreen.filterAll) {
      return result.where((Product item) => item.category == filter).toList();
    }
    return result;
  }

  /// @notice Builds the favorite list.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final List<Product> saved = _saved(ref.watch(favoritesProvider));
    final List<String> chips = _chipLabels(saved);
    final String filter = chips.contains(_filter)
        ? _filter
        : FavoriteScreen.filterAll;
    final List<Product> visible = _visible(saved, filter);
    final Color onShell = KosplyColors.textPrimaryOf(context);

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: PhosphorGlyph(PhosphorCode.arrowLeft, size: 20, color: onShell),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Favorite',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: onShell,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          KosplySearchbar(
            key: const Key('favorite-search'),
            hint: 'Cari favorite...',
            showFilter: false,
            onChanged: (String value) {
              setState(() => _query = value);
            },
          ),
          const SizedBox(height: 16),
          FilterChipBar(
            labels: chips,
            selected: filter,
            onSelected: (String label) => setState(() => _filter = label),
          ),
          const SizedBox(height: 16),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                saved.isEmpty
                    ? 'Belum ada barang favorite.'
                    : 'Belum ada barang di filter ini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: KosplyColors.textSecondaryOf(context),
                ),
              ),
            )
          else
            ProductGrid(items: visible),
        ],
      ),
    );
  }
}
