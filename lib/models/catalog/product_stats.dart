/// @title ProductStats
/// @notice One listing's numbers from `GET /api/analytics/products/:id`.
/// @author Kosply-mobile
library;

import '../../core/network/json_read.dart';

/// @title ProductStats
/// @notice Impressions, clicks, chats, and saves for a single product.
class ProductStats {
  /// @notice Creates the stats.
  /// @param impressions Feed and search views.
  /// @param clicks Detail opens.
  /// @param inquiries Buyers who opened a chat.
  /// @param favorites Current saves.
  /// @return A new {ProductStats} instance.
  const ProductStats({
    required this.impressions,
    required this.clicks,
    required this.inquiries,
    required this.favorites,
  });

  /// @notice Reads the `item` of the product stats route.
  /// @param item Backend row.
  /// @return The stats.
  factory ProductStats.fromJson(Map<String, dynamic> item) {
    return ProductStats(
      impressions: item.integer('impressions'),
      clicks: item.integer('clicks'),
      inquiries: item.integer('inquiries'),
      favorites: item.integer('favorites'),
    );
  }

  /// @dev Feed and search views.
  final int impressions;

  /// @dev Detail opens.
  final int clicks;

  /// @dev Buyers who opened a chat.
  final int inquiries;

  /// @dev Current saves.
  final int favorites;
}
