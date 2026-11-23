/// @title JualScreen
/// @notice Seller dashboard: identity, bio, catalogue search, and listing
/// actions.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/account/account_mode.dart';
import '../../../models/catalog/product.dart';
import '../../../models/catalog/seller.dart';
import '../../../providers/account/account_mode_provider.dart';
import '../../../providers/account/session_provider.dart';
import '../../../providers/catalog/catalog_providers.dart';
import '../../../providers/catalog/seller_analytics_provider.dart';
import '../../../core/ui_bridge/ui_bridge_scope.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/empty/empty_state_card.dart';
import '../../../widgets/common/filters/filter_chip_bar.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';
import '../../../widgets/product/grid/product_grid.dart';
import '../../../widgets/common/search/searchbar.dart';
import '../../../widgets/seller/identity/seller_identity.dart';
import '../../../widgets/common/buttons/tinted_icon_button.dart';
import '../../seller/product/add_product_screen.dart';
import '../../seller/analytic/analytic_screen.dart';

/// @title JualScreen
/// @notice Jual tab body.
class JualScreen extends ConsumerStatefulWidget {
  /// @notice Creates the jual screen.
  /// @return A new {JualScreen} instance.
  const JualScreen({super.key});

  /// @dev Tab shown first, listing every item the seller has.
  static const String filterAll = 'Semua';

  /// @dev Newest listings on the shelf.
  static const String filterTrading = 'Trading';

  /// @dev Listings ranked by clicks and impressions.
  static const String filterPopular = 'Paling diminati';

  /// @dev Listings with the least stock first.
  static const String filterLow = 'Hampir habis';

  /// @notice Creates the mutable search and filter state.
  /// @return The {_JualScreenState} instance.
  @override
  ConsumerState<JualScreen> createState() => _JualScreenState();
}

/// @title _JualScreenState
/// @notice Holds the catalogue query and selected chip.
class _JualScreenState extends ConsumerState<JualScreen> {
  String _query = '';
  String _filter = JualScreen.filterAll;

  /// @notice Labels for the chip bar: sort chips plus this seller's categories.
  /// @param items The seller's full catalogue.
  /// @return Chip labels in display order.
  List<String> _chipLabels(List<Product> items) {
    final List<String> labels = <String>[
      JualScreen.filterAll,
      JualScreen.filterTrading,
      JualScreen.filterPopular,
      JualScreen.filterLow,
    ];
    for (final Product item in items) {
      if (!labels.contains(item.category)) {
        labels.add(item.category);
      }
    }
    return labels;
  }

  /// @notice Applies search and the selected tab to [items].
  /// @param items The seller's full catalogue.
  /// @param interest Clicks plus impressions per product id.
  /// @return The filtered, possibly reordered list.
  List<Product> _visible(List<Product> items, Map<String, int> interest) {
    final String needle = _query.trim().toLowerCase();
    List<Product> result = items;
    if (needle.isNotEmpty) {
      result = result
          .where((Product item) => item.title.toLowerCase().contains(needle))
          .toList();
    }
    const Set<String> tabs = <String>{
      JualScreen.filterAll,
      JualScreen.filterTrading,
      JualScreen.filterPopular,
      JualScreen.filterLow,
    };
    if (!tabs.contains(_filter)) {
      return result.where((Product item) => item.category == _filter).toList();
    }
    if (_filter == JualScreen.filterPopular) {
      final List<Product> sorted = List<Product>.from(result);
      sorted.sort(
        (Product a, Product b) =>
            (interest[b.id] ?? 0).compareTo(interest[a.id] ?? 0),
      );
      return sorted;
    }
    if (_filter == JualScreen.filterLow) {
      final List<Product> sorted = List<Product>.from(result);
      sorted.sort((Product a, Product b) => a.quantity.compareTo(b.quantity));
      return sorted;
    }
    return result;
  }

  void _openAnalytic() {
    AnalyticScreen.push(context);
  }

  /// @notice Builds the seller dashboard.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    // @dev The shelf is the signed-in student's own: `GET /api/users/:id` and
    // @dev `GET /api/products?sellerId=` for their backend id.
    final String sellerId = ref.watch(currentUserIdProvider);
    ref.watch(sellerSyncProvider(sellerId));
    final Seller? seller = ref.watch(sellerProvider(sellerId)).value;
    final List<Product> listed =
        ref.watch(sellerProductsProvider(sellerId)).value ?? const <Product>[];
    final Map<String, int> interest =
        ref.watch(sellerAnalyticsProvider).value?.interestByProduct ??
        const <String, int>{};
    final List<Product> visible = _visible(listed, interest);
    final bool isSeller = ref.watch(accountModeProvider) == AccountMode.seller;

    if (seller == null) {
      return Scaffold(backgroundColor: KosplyColors.backgroundOf(context));
    }

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      body: UiBridgeScope(
        screen: 'jual',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          children: [
            SellerIdentity(seller: seller),
            const SizedBox(height: 12),
            Text(
              seller.bio,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: KosplyColors.textSecondaryOf(context),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: KosplySearchbar(
                    key: const Key('jual-search'),
                    hint: 'Cari barang jualan...',
                    showFilter: false,
                    onChanged: (String value) {
                      setState(() => _query = value);
                    },
                  ),
                ),
                if (isSeller) ...[
                  const SizedBox(width: 8),
                  TintedIconButton(
                    key: const Key('jual-analytic'),
                    codePoint: PhosphorCode.chartBar,
                    onPressed: _openAnalytic,
                  ),
                ],
                const SizedBox(width: 8),
                TintedIconButton(
                  key: const Key('jual-add'),
                  codePoint: PhosphorCode.plus,
                  onPressed: () => AddProductScreen.push(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilterChipBar(
              labels: _chipLabels(listed),
              selected: _filter,
              onSelected: (String label) => setState(() => _filter = label),
            ),
            const SizedBox(height: 16),
            if (visible.isEmpty)
              const EmptyStateCard(
                icon: PhosphorCode.package,
                message: 'Belum ada barang di filter ini.',
              )
            else
              ProductGrid(items: visible),
          ],
        ),
      ),
    );
  }
}
