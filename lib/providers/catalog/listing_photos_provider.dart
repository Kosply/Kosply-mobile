/// @title Listing photos provider
/// @notice Holds the photos captured for the listing being created.
/// @dev Auto-disposed: the camera screen watches it, so the photos survive
/// while the add-product form sits on top and are dropped once the seller
/// backs out of the camera.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/catalog/listing_photos.dart';

/// @title ListingPhotosNotifier
/// @notice Adds and removes captured listing photos.
class ListingPhotosNotifier extends Notifier<ListingPhotos> {
  /// @notice Starts with every slot empty.
  /// @return The initial {ListingPhotos}.
  @override
  ListingPhotos build() => ListingPhotos.empty();

  /// @notice Stores a new shot in the next empty slot.
  /// @param path Captured file path.
  /// @return void
  void add(String path) {
    state = state.withPhoto(path);
  }

  /// @notice Empties one slot.
  /// @param index Zero-based slot index.
  /// @return void
  void remove(int index) {
    state = state.without(index);
  }
}

/// @dev Photos for the listing in progress.
final listingPhotosProvider =
    NotifierProvider.autoDispose<ListingPhotosNotifier, ListingPhotos>(
      ListingPhotosNotifier.new,
    );
