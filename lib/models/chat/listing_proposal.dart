/// @title Listing proposal
/// @notice The four add-product fields the AI wants to write.
/// @dev Memory only. Setujui copies them into the form. Tolak drops them.
/// @author Kosply-mobile
library;

/// @title ListingProposal
/// @notice Nama, harga, deskripsi, and kategori for one preview.
class ListingProposal {
  /// @notice Creates a proposal.
  /// @param title Item name.
  /// @param price Integer rupiah.
  /// @param description Sales text.
  /// @param category Seeded category name.
  /// @return A new {ListingProposal} instance.
  const ListingProposal({
    required this.title,
    required this.price,
    required this.description,
    required this.category,
  });

  /// @dev Item name.
  final String title;

  /// @dev Integer rupiah.
  final int price;

  /// @dev Sales text.
  final String description;

  /// @dev Seeded category name.
  final String category;
}
