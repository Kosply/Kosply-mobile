/// @title AnalyticScreen
/// @notice Seller metrics plus catalogue sections spawned like Home.
/// @dev Tiles read `GET /api/analytics/seller` (last 30 days; saves are the
/// current count). The sections rank the signed-in seller's own shelf by that
/// interest and by remaining stock.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/catalog/product.dart';
import '../../../models/catalog/seller.dart';
import '../../../models/catalog/seller_analytics.dart';
import '../../../providers/account/session_provider.dart';
import '../../../providers/catalog/catalog_providers.dart';
import '../../../providers/catalog/seller_analytics_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/product/grid/product_grid.dart';
import '../../../widgets/common/headings/section_heading.dart';
import '../../../widgets/seller/appbar/seller_app_bar.dart';
import '../../main/home/see_all_screen.dart';

/// @title AnalyticScreen
/// @notice Analytic destination opened from Settings or Jual.
class AnalyticScreen extends ConsumerWidget {
  /// @notice Creates the analytic screen.
  /// @return A new {AnalyticScreen} instance.
  const AnalyticScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/analytic';

  /// @notice Tiles for [analytics]; dashes while it loads or failed.
  /// @param analytics Numbers from the backend, or null.
  /// @return Heading and value per tile.
  static List<(String, String)> metricsFor(SellerAnalytics? analytics) {
    String count(int? value) => value == null ? '–' : _grouped(value);
    return <(String, String)>[
      ('Views', count(analytics?.views)),
      ('Favorite', count(analytics?.favorites)),
      ('Chat', count(analytics?.chats)),
      ('Terjual', count(analytics?.sold)),
    ];
  }

  /// @notice Thousands with dots, e.g. 1284 → 1.284.
  /// @param value Count.
  /// @return The grouped digits.
  static String _grouped(int value) {
    final String digits = value.toString();
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        out.write('.');
      }
      out.write(digits[i]);
    }
    return out.toString();
  }

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
  /// @param ref Riverpod handle.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String sellerId = ref.watch(currentUserIdProvider);
    ref.watch(sellerSyncProvider(sellerId));
    final SellerAnalytics? analytics = ref.watch(sellerAnalyticsProvider).value;
    final List<(String, String)> metrics = metricsFor(analytics);
    final Seller? seller = ref.watch(sellerProvider(sellerId)).value;
    final List<Product> listed =
        ref.watch(sellerProductsProvider(sellerId)).value ?? const <Product>[];
    final List<Product> all =
        ref.watch(catalogProductsProvider).value ?? const <Product>[];
    final List<Product> trading = listed.take(4).toList();
    final Map<String, int> interest =
        analytics?.interestByProduct ?? const <String, int>{};
    final List<Product> byInterest = List<Product>.of(listed)
      ..sort(
        (Product a, Product b) =>
            (interest[b.id] ?? 0).compareTo(interest[a.id] ?? 0),
      );
    final List<Product> popular = byInterest.take(4).toList();
    final List<Product> byStock = List<Product>.of(listed)
      ..sort((Product a, Product b) => a.quantity.compareTo(b.quantity));
    final List<Product> lowStock = byStock.take(4).toList();
    final List<Product> recent = all.take(4).toList();

    if (seller == null) {
      return Scaffold(
        backgroundColor: KosplyColors.backgroundOf(context),
        appBar: AppBar(backgroundColor: KosplyColors.backgroundOf(context)),
      );
    }

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
            onTap: () => _openSeeAll(context, 'Paling diminati', byInterest),
          ),
          const SizedBox(height: 12),
          ProductGrid(items: popular),
          const SizedBox(height: 24),
          SectionHeading(
            'Hampir habis',
            actionLabel: 'Lihat semua',
            onTap: () => _openSeeAll(context, 'Hampir habis', byStock),
          ),
          const SizedBox(height: 12),
          ProductGrid(items: lowStock),
          const SizedBox(height: 24),
          SectionHeading(
            'Baru dilihat',
            actionLabel: 'Lihat semua',
            onTap: () => _openSeeAll(context, 'Baru dilihat', all),
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
