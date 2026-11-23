/// @title Favorites provider
/// @notice Holds product ids saved from the product-detail heart.
/// @dev Backed by the Drift cache; the in-memory set follows the
/// {favoriteIdsProvider} stream and toggles write through the repository,
/// which flips the heart at once and confirms it with `/api/favorites`.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_providers.dart';

/// @title FavoritesNotifier
/// @notice Mirrors the cached favorite ids for sync reads in widgets.
class FavoritesNotifier extends Notifier<Set<String>> {
  /// @notice Follows the cached favorite ids.
  /// @return The current favorite set, empty before the first read.
  @override
  Set<String> build() {
    return ref.watch(favoriteIdsProvider).value ?? const <String>{};
  }

  /// @notice Whether [productId] is currently saved.
  /// @param productId Catalogue item id.
  /// @return True when the id is in the set.
  bool contains(String productId) => state.contains(productId);

  /// @notice Adds [productId] when missing, removes it when already saved.
  /// @dev Throws {ApiException} when the server refused; the heart has
  /// already been flipped back by then.
  /// @param productId Catalogue item id.
  /// @return Future completing when the server agreed.
  Future<void> toggle(String productId) {
    return ref.read(catalogRepositoryProvider).toggleFavorite(productId);
  }
}

/// @dev Favorites view of the cache, refreshed whenever the table changes.
final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
