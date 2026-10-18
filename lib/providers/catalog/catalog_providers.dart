/// @title Catalog providers
/// @notice Exposes the offline-first catalogue to the product screens.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/providers/database_provider.dart';
import '../../data/catalog/catalog_repository.dart';
import '../../models/catalog/product.dart';
import '../../models/catalog/seller.dart';

/// @dev Catalogue repository backed by the Drift cache.
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(dao: ref.watch(appDatabaseProvider).catalogDao),
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
