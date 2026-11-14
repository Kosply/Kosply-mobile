/// @title SearchScreen
/// @notice Search tab: the shared search bar and the catalogue from the
/// backend, newest listings last in the "Dibuka terakhir" slice.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui_bridge/catalog_filter.dart';
import '../../../core/ui_bridge/ui_bridge.dart';
import '../../../core/ui_bridge/ui_bridge_scope.dart';
import '../../../core/ui_bridge/ui_ids.dart';
import '../../../models/catalog/product.dart';
import '../../../providers/catalog/catalog_providers.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/product/grid/product_grid.dart';
import '../../../widgets/common/search/catalog_search_field.dart';
import '../../../widgets/common/headings/section_heading.dart';
import '../home/see_all_screen.dart';

/// @title SearchScreen
/// @notice Search tab body.
class SearchScreen extends ConsumerWidget {
  /// @notice Creates the search screen.
  /// @return A new {SearchScreen} instance.
  const SearchScreen({super.key});

  void _openSeeAll(BuildContext context, List<Product> items) {
    SeeAllScreen.push(
      context,
      title: 'Dibuka terakhir',
      items: items.reversed.toList(),
    );
  }

  /// @notice Builds the search tab.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(catalogSyncProvider);
    final CatalogFilter filter = ref.watch(catalogFilterProvider);
    final List<Product> items =
        (ref.watch(catalogProductsProvider).value ?? const <Product>[])
            .where(filter.allows)
            .toList();
    final List<Product> recentItems = items.reversed.take(4).toList();

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      body: UiBridgeScope(
        screen: 'search',
        selection: filter.toJson(),
        elements: <UiElement>[
          UiElement(
            id: UiIds.input('search'),
            kind: UiElementKinds.input,
            label: 'Cari',
          ),
          for (final Product item in recentItems)
            UiElement.product(item.id, label: item.title),
        ],
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          children: [
            const CatalogSearchField(),
            const SizedBox(height: 24),
            SectionHeading(
              'Dibuka terakhir',
              actionLabel: 'Lihat semua',
              onTap: () => _openSeeAll(context, items),
            ),
            const SizedBox(height: 12),
            ProductGrid(items: recentItems, anchor: true, eventSource: 'search'),
          ],
        ),
      ),
    );
  }
}
