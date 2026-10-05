/// @title SellerDetailScreen
/// @notice Profile of a student seller: identity, bio, and their catalogue.
/// @dev Opened from the seller row on {ProductViewScreen}. Filters sit under
/// the "Barang jualan" heading and reshape the product grid in place.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../data/placeholder_catalog.dart';
import '../models/product.dart';
import '../models/seller.dart';
import '../theme/kosply_colors.dart';
import '../widgets/chat_seller_bar.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/product_grid.dart';
import '../widgets/section_heading.dart';
import '../widgets/seller_identity.dart';
import 'chat_detail_screen.dart';

/// @title SellerDetailScreen
/// @notice Seller profile and catalogue screen.
class SellerDetailScreen extends StatefulWidget {
  /// @notice Creates the seller screen.
  /// @param sellerId Identifier of the seller to show.
  /// @return A new {SellerDetailScreen} instance.
  const SellerDetailScreen({required this.sellerId, super.key});

  /// @dev Named route for this screen.
  static const routeName = '/seller';

  /// @dev Filter shown first, listing every item the seller has.
  static const String filterAll = 'Semua';

  /// @dev Newest-first filter.
  static const String filterNewest = 'Terbaru';

  /// @dev Lowest-price filter.
  static const String filterCheapest = 'Termurah';

  /// @dev Identifier of the seller to show.
  final String sellerId;

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @param sellerId Identifier of the seller to show.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context, String sellerId) {
    return Navigator.of(context).pushNamed(routeName, arguments: sellerId);
  }

  /// @notice Creates the mutable filter state.
  /// @return The {_SellerDetailScreenState} instance.
  @override
  State<SellerDetailScreen> createState() => _SellerDetailScreenState();
}

/// @title _SellerDetailScreenState
/// @notice Holds the selected catalogue filter.
class _SellerDetailScreenState extends State<SellerDetailScreen> {
  /// @dev Currently selected chip label.
  String _filter = SellerDetailScreen.filterAll;

  /// @notice Labels for the chip bar: sort chips plus this seller's categories.
  /// @param items The seller's full catalogue.
  /// @return Chip labels in display order.
  List<String> _chipLabels(List<Product> items) {
    final List<String> labels = <String>[
      SellerDetailScreen.filterAll,
      SellerDetailScreen.filterNewest,
      SellerDetailScreen.filterCheapest,
    ];
    for (final Product item in items) {
      if (!labels.contains(item.category)) {
        labels.add(item.category);
      }
    }
    return labels;
  }

  /// @notice Applies the selected chip to [items].
  /// @param items The seller's full catalogue.
  /// @return The filtered, possibly reordered list.
  List<Product> _filtered(List<Product> items) {
    if (_filter == SellerDetailScreen.filterNewest) {
      return items.reversed.toList();
    }
    if (_filter == SellerDetailScreen.filterCheapest) {
      final List<Product> sorted = List<Product>.from(items);
      sorted.sort(
        (Product a, Product b) => a.priceValue.compareTo(b.priceValue),
      );
      return sorted;
    }
    if (_filter != SellerDetailScreen.filterAll) {
      return items.where((Product item) => item.category == _filter).toList();
    }
    return items;
  }

  /// @notice Builds the seller profile.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final Seller seller = PlaceholderCatalog.sellerById(widget.sellerId);
    final List<Product> listed = PlaceholderCatalog.productsBySeller(
      widget.sellerId,
    );
    final List<Product> visible = _filtered(listed);

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: PhosphorGlyph(
            PhosphorCode.arrowLeft,
            size: 20,
            color: KosplyColors.textPrimaryOf(context),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          seller.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: KosplyColors.textPrimaryOf(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
          const SizedBox(height: 24),
          const SectionHeading('Barang jualan'),
          const SizedBox(height: 12),
          FilterChipBar(
            labels: _chipLabels(listed),
            selected: _filter,
            onSelected: (String label) => setState(() => _filter = label),
          ),
          const SizedBox(height: 16),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Belum ada barang di filter ini.',
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
      bottomNavigationBar: ChatSellerBar(
        onPressed: () => ChatDetailScreen.push(context, widget.sellerId),
      ),
    );
  }
}
