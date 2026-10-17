/// @title Price labels
/// @notice Formats cached integer prices into the "Rp.375.000" app style.
/// @author Kosply-mobile
library;

/// @notice Formats a rupiah amount with dot thousand separators.
/// @param price Amount stored in the backend `products.price` column.
/// @return The label, e.g. "Rp.375.000".
String priceLabel(int price) {
  final String digits = price.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  final String sign = price < 0 ? '-' : '';
  return 'Rp.$sign$buffer';
}
