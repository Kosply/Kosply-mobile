/// @title Catalogue sort
/// @notice Price and distance orders for the search results sheet.
/// @dev Explicit distance orders keep far pins. The home feed still uses
/// [nearestFirst] and may hide pins outside the campus radius.
/// @author Kosply-mobile
library;

import '../../models/catalog/product.dart';
import '../location/device_location.dart';
import '../location/nearby.dart';

/// @title CatalogSort
/// @notice One row in the search filter sheet.
enum CatalogSort {
  /// @dev Lowest rupiah first.
  termurah,

  /// @dev Highest rupiah first.
  termahal,

  /// @dev Closest pin first. Unpinned listings stay at the end.
  terdekat,

  /// @dev Farthest pin first. Unpinned listings stay at the end.
  terjauh;

  /// @notice Indonesian label shown on the sheet.
  String get label {
    switch (this) {
      case CatalogSort.termurah:
        return 'Termurah';
      case CatalogSort.termahal:
        return 'Termahal';
      case CatalogSort.terdekat:
        return 'Terdekat';
      case CatalogSort.terjauh:
        return 'Terjauh';
    }
  }
}

/// @notice Orders [items] by [sort].
/// @dev Price ties keep the incoming order. Distance sorts do nothing when
/// [fix] has no pin, and they never drop a far listing.
/// @param items Products already narrowed by query and category.
/// @param sort Chosen sheet row.
/// @param fix Viewer position for the distance rows.
/// @return A new list.
List<Product> sortCatalogue(
  List<Product> items,
  CatalogSort sort, {
  DeviceFix? fix,
}) {
  switch (sort) {
    case CatalogSort.termurah:
      return _byPrice(items, ascending: true);
    case CatalogSort.termahal:
      return _byPrice(items, ascending: false);
    case CatalogSort.terdekat:
      return nearestFirst(items, fix: fix, keepFar: true);
    case CatalogSort.terjauh:
      return farthestFirst(items, fix: fix);
  }
}

/// @notice Sorts by rupiah, keeping the original order when prices match.
/// @param items Products to order.
/// @param ascending True for termurah.
/// @return A new list.
List<Product> _byPrice(List<Product> items, {required bool ascending}) {
  final List<int> order = List<int>.generate(items.length, (int i) => i);
  order.sort((int a, int b) {
    final int price = ascending
        ? items[a].priceValue.compareTo(items[b].priceValue)
        : items[b].priceValue.compareTo(items[a].priceValue);
    return price != 0 ? price : a.compareTo(b);
  });
  return <Product>[for (final int index in order) items[index]];
}
