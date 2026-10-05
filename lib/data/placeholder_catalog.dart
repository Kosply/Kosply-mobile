/// @title PlaceholderCatalog
/// @notice Stand-in catalogue used until the product API is wired up.
/// @dev Keeps the id-to-product lookup in one place so screens only ever hold
/// an id, which is what the detail route is meant to receive.
/// @author Kosply-mobile
library;

import '../models/product.dart';
import '../models/seller.dart';

/// @title PlaceholderCatalog
/// @notice Fake data source for the home feed, detail screen and reviews.
class PlaceholderCatalog {
  // @dev Prevents instantiation of this utility holder.
  const PlaceholderCatalog._();

  /// @dev Number of placeholder products.
  /// @dev Four sellers times four listings keeps every catalogue grid even.
  static const int productCount = 16;

  /// @notice All placeholder products.
  /// @return The catalogue as a list.
  static List<Product> all() {
    return List<Product>.generate(productCount, Product.placeholder);
  }

  /// @notice Looks a product up by id.
  /// @dev Falls back to the first entry so a bad id still renders a screen
  /// @dev instead of throwing.
  /// @param id Identifier taken from [Product.id].
  /// @return The matching product, or a fallback.
  static Product byId(String id) {
    final List<Product> items = all();
    for (final Product item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return items.first;
  }

  /// @notice Looks a seller up by id.
  /// @dev Falls back to the first seller so a bad id still renders a screen.
  /// @param id Identifier taken from [Seller.id].
  /// @return The matching seller, or a fallback.
  static Seller sellerById(String id) {
    for (int i = 0; i < Seller.count; i++) {
      final Seller seller = Seller.placeholder(i);
      if (seller.id == id) {
        return seller;
      }
    }
    return Seller.placeholder(0);
  }

  /// @notice Catalogue items listed by one seller.
  /// @param sellerId Identifier taken from [Seller.id].
  /// @return The seller's products in catalogue order.
  static List<Product> productsBySeller(String sellerId) {
    return all().where((Product item) => item.sellerId == sellerId).toList();
  }
}
