/// @title AnalyticScreen
/// @notice Seller metrics plus catalogue sections spawned like Home.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../data/placeholder_catalog.dart';
import '../models/product.dart';
import '../models/seller.dart';
import '../theme/kosply_colors.dart';
import '../widgets/product_grid.dart';
import '../widgets/section_heading.dart';
import '../widgets/seller_app_bar.dart';
import 'see_all_screen.dart';

/// @title AnalyticScreen
/// @notice Analytic destination opened from Settings or Jual.
class AnalyticScreen extends StatelessWidget {
  /// @notice Creates the analytic screen.
  /// @return A new {AnalyticScreen} instance.
  const AnalyticScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/analytic';

  /// @dev Signed-in student whose metrics are shown.
  static const String sellerId = 'seller-1';

  /// @dev Placeholder metric tiles: heading plus a left-aligned number.
  static const List<(String, String)> metrics = <(String, String)>[
    ('Views', '1.284'),
    ('Favorite', '46'),
    ('Chat', '18'),
    ('Terjual', '7'),
  ];

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  void _openSeeAll(BuildContext context, String title, List<Product> items) {
    SeeAllScreen.push(context, title: title, items: items);
  }

  /// @notice Builds the metric grid and catalogue sections.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final Seller seller = PlaceholderCatalog.sellerById(sellerId);
    final List<Product> listed = PlaceholderCatalog.productsBySeller(sellerId);
    final List<Product> all = PlaceholderCatalog.all();
    final List<Product> trading = listed.isEmpty
        ? all.take(4).toList()
        : listed.take(4).toList();
    final List<Product> popular = all.take(4).toList();
    final List<Product> lowStock = all.skip(4).take(4).toList();
    final List<Product> recent = all.reversed.take(4).toList();

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: SellerAppBar(seller: seller),
      body: ListView(
        key: const Key('analytic-scroll'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _MetricGrid(metrics: metrics),
          const SizedBox(height: 24),
          SectionHeading(
            'Trading product kamu',
            actionLabel: 'Lihat semua',
            onTap: () => _openSeeAll(context, 'Trading product kamu', trading),
          ),
          const SizedBox(height: 12),
          ProductGrid(items: trading),
          const SizedBox(height: 24),
          SectionHeading(
            'Paling diminati',
            actionLabel: 'Lihat semua',
            onTap: () => _openSeeAll(context, 'Paling diminati', all),
          ),
          const SizedBox(height: 12),
          ProductGrid(items: popular),
          const SizedBox(height: 24),
          SectionHeading(
            'Hampir habis',
            actionLabel: 'Lihat semua',
            onTap: () => _openSeeAll(context, 'Hampir habis', all),
          ),
          const SizedBox(height: 12),
          ProductGrid(items: lowStock),
          const SizedBox(height: 24),
          SectionHeading(
            'Baru dilihat',
            actionLabel: 'Lihat semua',
            onTap: () =>
                _openSeeAll(context, 'Baru dilihat', all.reversed.toList()),
          ),
          const SizedBox(height: 12),
          ProductGrid(items: recent),
        ],
      ),
    );
  }
}

/// @title _MetricGrid
/// @notice Two-by-two cards of left-aligned headings and numbers.
class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<(String, String)> metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: 12),
          Row(
            children: [
              for (int col = 0; col < 2; col++) ...[
                if (col > 0) const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: metrics[row * 2 + col].$1,
                    value: metrics[row * 2 + col].$2,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// @title _MetricCard
/// @notice One analytic tile: heading stacked above a left-aligned number.
class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: KosplyColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KosplyColors.outlineOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: KosplyColors.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: KosplyColors.textPrimaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
