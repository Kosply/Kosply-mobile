/// @title SellerAnalytics
/// @notice The seller's own numbers from `GET /api/analytics/seller`.
/// @dev Totals feed the four Analytics tiles; per-product rows rank the
/// seller's shelf. Counts are for the requested window except [favorites],
/// which is the current number of saves.
/// @author Kosply-mobile
library;

import '../../core/network/json_read.dart';

/// @title SellerAnalytics
/// @notice Catalogue totals plus interest per product.
class SellerAnalytics {
  /// @notice Creates the analytics.
  /// @param views Feed and search impressions.
  /// @param favorites Current saves across the shelf.
  /// @param chats Buyers who opened a chat about a listing.
  /// @param sold Listings sold in the window.
  /// @param interestByProduct Clicks plus impressions per product id.
  /// @return A new {SellerAnalytics} instance.
  const SellerAnalytics({
    required this.views,
    required this.favorites,
    required this.chats,
    required this.sold,
    this.interestByProduct = const <String, int>{},
  });

  /// @notice Reads the `item` of `GET /api/analytics/seller`.
  /// @param item `{range, totals, items}`.
  /// @return The analytics.
  factory SellerAnalytics.fromJson(Map<String, dynamic> item) {
    final Map<String, dynamic> totals =
        item.object('totals') ?? const <String, dynamic>{};
    return SellerAnalytics(
      views: totals.integer('impressions'),
      favorites: totals.integer('favorites'),
      chats: totals.integer('inquiries'),
      sold: totals.integer('sales'),
      interestByProduct: <String, int>{
        for (final Map<String, dynamic> row in item.objects('items'))
          row.str('productId'): row.integer('clicks') + row.integer('impressions'),
      },
    );
  }

  /// @dev Feed and search impressions.
  final int views;

  /// @dev Current saves across the shelf.
  final int favorites;

  /// @dev Buyers who opened a chat about a listing.
  final int chats;

  /// @dev Listings sold in the window.
  final int sold;

  /// @dev Clicks plus impressions per product id.
  final Map<String, int> interestByProduct;
}
