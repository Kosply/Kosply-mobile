/// @title ListingPhotos
/// @notice Photo slots a seller fills from the camera before listing an item.
/// @author Kosply-mobile
library;

/// @title ListingPhotos
/// @notice Immutable, fixed-size set of captured photo paths.
/// @dev Removing a photo leaves its slot empty so the next shot refills that
/// slot instead of shifting the others.
class ListingPhotos {
  /// @notice Creates a slot set.
  /// @param slots One captured file path per slot, null when empty.
  /// @return A new {ListingPhotos} instance.
  const ListingPhotos(this.slots);

  /// @notice Creates a set with every slot empty.
  /// @return A {ListingPhotos} with [required] empty slots.
  factory ListingPhotos.empty() =>
      ListingPhotos(List<String?>.filled(required, null));

  /// @dev Photos a listing needs before the add-product form opens.
  static const int required = 5;

  /// @dev Captured file path per slot, null when empty.
  final List<String?> slots;

  /// @notice Number of filled slots.
  /// @return Count of non-empty slots.
  int get count => slots.where((String? path) => path != null).length;

  /// @notice Captured paths in slot order, skipping empty slots.
  /// @return The filled paths; the first one is the cover.
  List<String> get paths => slots.whereType<String>().toList();

  /// @notice Whether every slot holds a photo.
  /// @return True when [count] reaches [required].
  bool get isComplete => count == required;

  /// @notice Slot the next shot goes into.
  /// @return The first empty slot index, or null when complete.
  int? get nextSlot {
    final int index = slots.indexOf(null);
    return index < 0 ? null : index;
  }

  /// @notice Stores [path] in the first empty slot.
  /// @param path Captured file path.
  /// @return The updated set, or this set when already complete.
  ListingPhotos withPhoto(String path) {
    final int? index = nextSlot;
    if (index == null) {
      return this;
    }
    return ListingPhotos(List<String?>.of(slots)..[index] = path);
  }

  /// @notice Empties the slot at [index].
  /// @param index Zero-based slot index.
  /// @return The updated set.
  ListingPhotos without(int index) {
    return ListingPhotos(List<String?>.of(slots)..[index] = null);
  }
}
