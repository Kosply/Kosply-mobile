/// @title Catalog filter
/// @notice The filter the AI applies to the home and search catalogues.
/// @dev `apply_filter` writes it; `clear_filter` resets it. Screens publish
/// the same values back in `ui_state.selection` on the next turn.
/// @author Kosply-mobile
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/catalog/product.dart';

/// @title CatalogFilter
/// @notice Query, category, and price cap currently narrowing the catalogue.
class CatalogFilter {
  /// @notice Creates a filter.
  /// @param query Free-text match against the title and category.
  /// @param category Category substring. Empty means every category.
  /// @param maxPrice Highest price in rupiah, or null when uncapped.
  /// @return A new {CatalogFilter} instance.
  const CatalogFilter({this.query = '', this.category = '', this.maxPrice});

  /// @dev Free-text match against the title and category.
  final String query;

  /// @dev Category substring.
  final String category;

  /// @dev Highest price in rupiah.
  final int? maxPrice;

  /// @notice Whether any constraint is set.
  bool get isActive =>
      query.trim().isNotEmpty ||
      category.trim().isNotEmpty ||
      maxPrice != null;

  /// @notice Whether [product] survives this filter.
  /// @param product Catalogue item.
  /// @return True when every set constraint matches.
  bool allows(Product product) {
    final String title = product.title.toLowerCase();
    final String kind = product.category.toLowerCase();
    final String words = query.trim().toLowerCase();
    if (words.isNotEmpty && !title.contains(words) && !kind.contains(words)) {
      return false;
    }
    final String wanted = category.trim().toLowerCase();
    if (wanted.isNotEmpty && !kind.contains(wanted)) {
      return false;
    }
    final int? cap = maxPrice;
    if (cap != null && product.priceValue > cap) {
      return false;
    }
    return true;
  }

  /// @notice JSON placed in `ui_state.selection`.
  /// @return The active constraints.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      if (query.trim().isNotEmpty) 'query': query.trim(),
      if (category.trim().isNotEmpty) 'category': category.trim(),
      if (maxPrice != null) 'maxPrice': maxPrice,
    };
  }
}

/// @title CatalogFilterNotifier
/// @notice Holds the catalogue filter the AI and the search field share.
class CatalogFilterNotifier extends Notifier<CatalogFilter> {
  /// @notice Starts with no constraints.
  /// @return An empty {CatalogFilter}.
  @override
  CatalogFilter build() => const CatalogFilter();

  /// @notice Replaces the filter from one `apply_filter` callback.
  /// @param query Free text. Empty leaves the previous query when omitted
  /// by the caller; pass [replace] to set exactly these fields.
  /// @param category Category substring.
  /// @param maxPrice Price cap in rupiah.
  /// @param replace When true, omitted fields are cleared.
  /// @return void
  void apply({
    String? query,
    String? category,
    int? maxPrice,
    bool clearPrice = false,
    bool replace = false,
  }) {
    state = CatalogFilter(
      query: query ?? (replace ? '' : state.query),
      category: category ?? (replace ? '' : state.category),
      maxPrice: clearPrice
          ? null
          : (maxPrice ?? (replace ? null : state.maxPrice)),
    );
  }

  /// @notice Sets only the free-text query, keeping category and price.
  /// @param query Text from the search field.
  /// @return void
  void setQuery(String query) {
    state = CatalogFilter(
      query: query,
      category: state.category,
      maxPrice: state.maxPrice,
    );
  }

  /// @notice Drops every constraint.
  /// @return void
  void clear() => state = const CatalogFilter();
}

/// @dev Active catalogue filter.
final catalogFilterProvider =
    NotifierProvider<CatalogFilterNotifier, CatalogFilter>(
      CatalogFilterNotifier.new,
    );

/// @dev Focus node shared by the catalogue search field on the visible tab.
final catalogSearchFocusProvider = Provider<FocusNode>((Ref ref) {
  final FocusNode node = FocusNode();
  ref.onDispose(node.dispose);
  return node;
});
