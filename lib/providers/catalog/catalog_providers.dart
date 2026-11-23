/// @title Catalog providers
/// @notice Exposes the offline-first catalogue to the product screens.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers/database_provider.dart';
import '../../core/network/api_exception.dart';
import '../../data/catalog/catalog_repository.dart';
import '../../models/catalog/product.dart';
import '../../models/catalog/seller.dart';
import '../network/api_provider.dart';
import 'catalog_events.dart';

/// @dev Catalogue repository backed by the Drift cache.
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(
    dao: ref.watch(appDatabaseProvider).catalogDao,
    api: ref.watch(apiClientProvider),
  ),
);

/// @dev Every cached product with its seller attached, in backend order.
final catalogProductsProvider = StreamProvider<List<Product>>(
  (ref) => ref.watch(catalogRepositoryProvider).watchProducts(),
);

/// @dev One cached product, or null when the id is unknown.
final catalogProductProvider = StreamProvider.family<Product?, String>(
  (ref, String id) => ref.watch(catalogRepositoryProvider).watchProduct(id),
);

/// @dev The listings of one seller, in backend order.
final sellerProductsProvider = StreamProvider.family<List<Product>, String>(
  (ref, String sellerId) =>
      ref.watch(catalogRepositoryProvider).watchProductsBySeller(sellerId),
);

/// @dev One cached seller, or null when the id is unknown.
final sellerProvider = StreamProvider.family<Seller?, String>(
  (ref, String sellerId) =>
      ref.watch(catalogRepositoryProvider).watchSeller(sellerId),
);

/// @dev The saved products in save order.
final favoriteProductsProvider = StreamProvider<List<Product>>(
  (ref) => ref.watch(catalogRepositoryProvider).watchFavoriteProducts(),
);

/// @dev The saved product ids, oldest saved first.
final favoriteIdsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(catalogRepositoryProvider).watchFavoriteIds(),
);

/// @notice Runs a refresh and ignores backend or network failures.
/// @dev Screens watch the cache, so a failed refresh only means the last good
/// copy stays on screen; nothing to surface.
/// @param refresh The repository refresh.
/// @return Future completing when it settled.
Future<void> refreshQuietly(Future<void> Function() refresh) async {
  try {
    await refresh();
  } on ApiException {
    return;
  }
}

/// @dev Re-reads the public catalogue each time Home or Search is shown.
final catalogSyncProvider = FutureProvider.autoDispose<void>(
  (ref) => refreshQuietly(ref.read(catalogRepositoryProvider).refresh),
);

/// @dev Pulls one product's detail when it is opened, and records the click.
final productSyncProvider = FutureProvider.autoDispose.family<void, String>((
  ref,
  String id,
) async {
  await refreshQuietly(
    () => ref.read(catalogRepositoryProvider).refreshProduct(id),
  );
  ref.read(catalogEventsProvider).click(id);
});

/// @dev Pulls a seller's profile and shelf when it is opened.
final sellerSyncProvider = FutureProvider.autoDispose.family<void, String>(
  (ref, String sellerId) => refreshQuietly(
    () => ref.read(catalogRepositoryProvider).refreshSeller(sellerId),
  ),
);

/// @dev Re-reads the saved list when the favorites screen is shown.
final favoritesSyncProvider = FutureProvider.autoDispose<void>(
  (ref) => refreshQuietly(ref.read(catalogRepositoryProvider).refreshFavorites),
);
