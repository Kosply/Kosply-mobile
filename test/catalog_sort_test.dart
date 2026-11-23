/// @title Catalogue sort tests
/// @notice Price order and distance order used by the search filter sheet.
/// @author Kosply-mobile
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/location/device_location.dart';
import 'package:kosply_mobile/core/ui_bridge/catalog_sort.dart';
import 'package:kosply_mobile/models/catalog/product.dart';

Product _item(
  String id,
  String price, {
  double latitude = 0,
  double longitude = 0,
}) {
  return Product(
    id: id,
    title: id,
    price: price,
    location: '',
    imagePath: Product.placeholderImage,
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  const DeviceFix jakarta = DeviceFix(
    latitude: -6.2,
    longitude: 106.8,
    label: 'Jakarta',
  );

  test('termurah and termahal order by rupiah and keep ties', () {
    final List<Product> items = <Product>[
      _item('mid', 'Rp.80.000'),
      _item('low-a', 'Rp.45.000'),
      _item('high', 'Rp.1.250.000'),
      _item('low-b', 'Rp.45.000'),
    ];

    expect(
      sortCatalogue(items, CatalogSort.termurah).map((Product p) => p.id),
      <String>['low-a', 'low-b', 'mid', 'high'],
    );
    expect(
      sortCatalogue(items, CatalogSort.termahal).map((Product p) => p.id),
      <String>['high', 'mid', 'low-a', 'low-b'],
    );
  });

  test('distance sorts keep far pins and park unpinned listings last', () {
    final List<Product> items = <Product>[
      _item('loose', 'Rp.10.000'),
      _item('far', 'Rp.20.000', latitude: -7.2, longitude: 108.5),
      _item('near', 'Rp.30.000', latitude: -6.21, longitude: 106.81),
    ];

    expect(
      sortCatalogue(
        items,
        CatalogSort.terdekat,
        fix: jakarta,
      ).map((Product p) => p.id),
      <String>['near', 'far', 'loose'],
    );
    expect(
      sortCatalogue(
        items,
        CatalogSort.terjauh,
        fix: jakarta,
      ).map((Product p) => p.id),
      <String>['far', 'near', 'loose'],
    );
  });

  test('distance sorts leave the list alone without a viewer pin', () {
    final List<Product> items = <Product>[
      _item('far', 'Rp.20.000', latitude: -7.2, longitude: 108.5),
      _item('near', 'Rp.30.000', latitude: -6.21, longitude: 106.81),
    ];
    const DeviceFix missing = DeviceFix(
      latitude: 0,
      longitude: 0,
      label: 'Lokasimu',
    );

    expect(
      sortCatalogue(
        items,
        CatalogSort.terdekat,
        fix: missing,
      ).map((Product p) => p.id),
      <String>['far', 'near'],
    );
    expect(
      sortCatalogue(
        items,
        CatalogSort.terjauh,
        fix: null,
      ).map((Product p) => p.id),
      <String>['far', 'near'],
    );
  });
}
