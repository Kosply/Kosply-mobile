/// @title Seller analytics provider
/// @notice The signed-in seller's numbers for the Analytics screen.
/// @dev Fetched on open, for the last [sellerAnalyticsDays] days. Not cached
/// in Drift: these are live counters, and a stale number would mislead more
/// than a loading tile.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/json_read.dart';
import '../../data/catalog/catalog_repository.dart';
import '../../models/catalog/product_stats.dart';
import '../../models/catalog/seller_analytics.dart';
import '../network/api_provider.dart';
import 'catalog_providers.dart';

/// @dev Window the Analytics screen reports on.
const int sellerAnalyticsDays = 30;

/// @dev `GET /api/analytics/seller` for the signed-in seller.
final sellerAnalyticsProvider = FutureProvider.autoDispose<SellerAnalytics>((
  ref,
) async {
  final Map<String, dynamic> json = await ref
      .read(apiClientProvider)
      .get(
        '/api/analytics/seller',
        query: <String, String>{'days': '$sellerAnalyticsDays'},
      );
  return SellerAnalytics.fromJson(
    json.object('item') ?? const <String, dynamic>{},
  );
});

/// @dev `GET /api/analytics/products/:id` for a listing the seller owns.
final productStatsProvider = FutureProvider.autoDispose
    .family<ProductStats, String>((ref, String id) {
      final CatalogRepository repo = ref.watch(catalogRepositoryProvider);
      return repo.productStats(id);
    });
