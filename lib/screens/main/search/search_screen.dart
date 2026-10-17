/// @title SearchScreen
/// @notice Search tab: the shared search bar, recent queries, and last-opened
/// catalogue items.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/catalog/product.dart';
import '../../../providers/catalog/catalog_providers.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/filters/filter_chip_bar.dart';
import '../../../widgets/product/grid/product_grid.dart';
import '../../../widgets/common/search/searchbar.dart';
import '../../../widgets/common/headings/section_heading.dart';
import '../home/see_all_screen.dart';

/// @title SearchScreen
/// @notice Search tab body.
class SearchScreen extends ConsumerStatefulWidget {
  /// @notice Creates the search screen.
  /// @return A new {SearchScreen} instance.
  const SearchScreen({super.key});

  /// @dev Placeholder recent queries shown as a horizontal chip carousel.
  static const List<String> history = <String>[
    'Meja belajar',
    'Kipas angin',
    'Rice cooker',
    'Kasur busa',
    'Lampu LED',
    'Rak sepatu',
  ];

  /// @notice Creates the mutable chip state.
  /// @return The {_SearchScreenState} instance.
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

/// @title _SearchScreenState
/// @notice Holds the selected history chip.
class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _selectedHistory = SearchScreen.history.first;

  void _openSeeAll(BuildContext context, List<Product> items) {
    SeeAllScreen.push(
      context,
      title: 'Dibuka terakhir',
      items: items.reversed.toList(),
    );
  }

  /// @notice Builds the search tab.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final List<Product> items =
        ref.watch(catalogProductsProvider).value ?? const <Product>[];
    final List<Product> recentItems = items.reversed.take(4).toList();

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const KosplySearchbar(),
          const SizedBox(height: 24),
          const SectionHeading('Riwayat pencarian'),
          const SizedBox(height: 12),
          FilterChipBar(
            labels: SearchScreen.history,
            selected: _selectedHistory,
            onSelected: (String label) {
              setState(() => _selectedHistory = label);
            },
          ),
          const SizedBox(height: 24),
          SectionHeading(
            'Dibuka terakhir',
            actionLabel: 'Lihat semua',
            onTap: () => _openSeeAll(context, items),
          ),
          const SizedBox(height: 12),
          ProductGrid(items: recentItems),
        ],
      ),
    );
  }
}
