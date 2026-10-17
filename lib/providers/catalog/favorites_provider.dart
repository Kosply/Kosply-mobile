/// @title Favorites provider
/// @notice Holds product ids saved from the product-detail heart.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// @title FavoritesNotifier
/// @notice Mutates the in-memory favorite id set.
class FavoritesNotifier extends Notifier<Set<String>> {
  /// @notice Starts with no saved products.
  /// @return The empty favorite set.
  @override
  Set<String> build() => <String>{};

  /// @notice Whether [productId] is currently saved.
  /// @param productId Catalogue item id.
  /// @return True when the id is in the set.
  bool contains(String productId) => state.contains(productId);

  /// @notice Adds [productId] when missing, removes it when already saved.
  /// @param productId Catalogue item id.
  /// @return void
  void toggle(String productId) {
    final Set<String> next = Set<String>.from(state);
    if (!next.remove(productId)) {
      next.add(productId);
    }
    state = next;
  }
}

/// @dev Session-scoped favorites. Empty until a product-detail heart is tapped.
final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
