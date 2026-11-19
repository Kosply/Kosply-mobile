/// @title Nearby catalogue
/// @notice Orders public product lists from the viewer's position.
/// @dev Listings stored as `0,0` have no pin. They stay in the list so an
/// older catalogue does not disappear. Pinned listings farther than
/// [nearbyRadiusKm] drop out only when at least one pinned listing is inside
/// that radius.
/// @author Kosply-mobile
library;

import 'dart:math' as math;

import '../../models/catalog/product.dart';
import 'device_location.dart';

/// @dev Campus-scale cutoff. Farther pinned listings hide when something
/// closer is already on screen.
const double nearbyRadiusKm = 18;

/// @notice Great-circle distance in kilometres.
/// @param latitudeA First latitude.
/// @param longitudeA First longitude.
/// @param latitudeB Second latitude.
/// @param longitudeB Second longitude.
/// @return Distance in kilometres.
double distanceKm(
  double latitudeA,
  double longitudeA,
  double latitudeB,
  double longitudeB,
) {
  const double earthKm = 6371;
  double radians(double degrees) => degrees * math.pi / 180;
  final double dLat = radians(latitudeB - latitudeA);
  final double dLon = radians(longitudeB - longitudeA);
  final double a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(radians(latitudeA)) *
          math.cos(radians(latitudeB)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return earthKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

/// @notice True when [product] has a stored pin.
/// @param product Catalogue item.
/// @return False for the unset `0,0` default.
bool productHasPin(Product product) {
  return product.latitude.abs() > 0.000001 ||
      product.longitude.abs() > 0.000001;
}

/// @notice Puts the closest pinned products first.
/// @param items Products in their current order.
/// @param fix Viewer position. Null or unpinned leaves [items] as they are.
/// @param keepFar When true, far pinned products stay (favorites). When
/// false, they drop once something inside [nearbyRadiusKm] exists.
/// @return The ordered list. Unpinned products keep their relative order
/// and follow the pinned ones.
List<Product> nearestFirst(
  List<Product> items, {
  DeviceFix? fix,
  bool keepFar = false,
}) {
  if (fix == null || !fix.hasPin || items.length < 2) {
    return items;
  }
  final List<Product> pinned = <Product>[];
  final List<Product> loose = <Product>[];
  for (final Product item in items) {
    if (productHasPin(item)) {
      pinned.add(item);
    } else {
      loose.add(item);
    }
  }
  if (pinned.isEmpty) {
    return items;
  }
  double away(Product item) {
    return distanceKm(
      fix.latitude,
      fix.longitude,
      item.latitude,
      item.longitude,
    );
  }

  pinned.sort((Product a, Product b) => away(a).compareTo(away(b)));
  final List<Product> visible = keepFar
      ? pinned
      : pinned.where((Product item) => away(item) <= nearbyRadiusKm).toList();
  return <Product>[...(visible.isEmpty ? pinned : visible), ...loose];
}

/// @notice Puts the farthest pinned products first.
/// @dev Unpinned listings stay at the end. A missing viewer pin leaves
/// [items] unchanged, the same rule as [nearestFirst].
/// @param items Products in their current order.
/// @param fix Viewer position.
/// @return The ordered list.
List<Product> farthestFirst(List<Product> items, {DeviceFix? fix}) {
  if (fix == null || !fix.hasPin || items.length < 2) {
    return items;
  }
  final List<Product> pinned = <Product>[];
  final List<Product> loose = <Product>[];
  for (final Product item in items) {
    if (productHasPin(item)) {
      pinned.add(item);
    } else {
      loose.add(item);
    }
  }
  if (pinned.isEmpty) {
    return items;
  }
  double away(Product item) {
    return distanceKm(
      fix.latitude,
      fix.longitude,
      item.latitude,
      item.longitude,
    );
  }

  pinned.sort((Product a, Product b) => away(b).compareTo(away(a)));
  return <Product>[...pinned, ...loose];
}
