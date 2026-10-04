/// @title SearchScreen
/// @notice Search tab: the shared search bar, recent queries, and last-opened
/// catalogue items.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../data/placeholder_catalog.dart';
import '../models/product.dart';
import '../theme/kosply_colors.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/product_grid.dart';
import '../widgets/searchbar.dart';
import '../widgets/section_heading.dart';
import 'see_all_screen.dart';

/// @title SearchScreen
/// @notice Search tab body.
class SearchScreen extends StatefulWidget {
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
  State<SearchScreen> createState() => _SearchScreenState();
}

/// @title _SearchScreenState
/// @notice Holds the selected history chip.
class _SearchScreenState extends State<SearchScreen> {
  String _selectedHistory = SearchScreen.history.first;

  static final List<Product> _recentItems = PlaceholderCatalog.all().reversed
      .take(4)
      .toList();

  void _openSeeAll(BuildContext context) {
    SeeAllScreen.push(
      context,
      title: 'Dibuka terakhir',
      items: PlaceholderCatalog.all().reversed.toList(),
    );
  }

  /// @notice Builds the search tab.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
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
            onTap: () => _openSeeAll(context),
          ),
          const SizedBox(height: 12),
          ProductGrid(items: _recentItems),
        ],
      ),
    );
  }
}
