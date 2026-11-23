/// @title ListingCard
/// @notice The product card the AI fills from side photos.
/// @dev Shape of `listing` on `POST /api/ai/chat` (`agent_spec/tables/
/// listing.md`). The model owns [title], [description] and [category]; the
/// add-product form shows them read-only so the listing matches the photos.
/// The seller types price, quantity and the meeting point.
/// @author Kosply-mobile
library;

import '../../core/network/json_read.dart';

/// @title ListingCard
/// @notice AI-written listing text plus the photo URLs it describes.
class ListingCard {
  /// @notice Creates a card.
  /// @param title Item name, at most 191 characters.
  /// @param description Item description.
  /// @param category Free-text category.
  /// @param imageUrls Photo URLs, cover first.
  /// @return A new {ListingCard} instance.
  const ListingCard({
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrls,
  });

  /// @notice Reads the `listing` object of an AI turn.
  /// @param json The `listing` object.
  /// @return The card.
  factory ListingCard.fromJson(Map<String, dynamic> json) {
    return ListingCard(
      title: json.str('title'),
      description: json.str('description'),
      category: json.str('category'),
      imageUrls: json.strings('imageUrls'),
    );
  }

  /// @dev Item name, at most 191 characters.
  final String title;

  /// @dev Item description.
  final String description;

  /// @dev Free-text category.
  final String category;

  /// @dev Photo URLs, cover first.
  final List<String> imageUrls;
}
