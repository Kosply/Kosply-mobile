/// @title Nearby ordering
/// @notice Distance sort used by Home, search results, and related cards.
/// @author Kosply-mobile
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/location/device_location.dart';
import 'package:kosply_mobile/core/location/nearby.dart';
import 'package:kosply_mobile/core/location/place_search.dart';
import 'package:kosply_mobile/models/catalog/product.dart';

Product _item(String id, {double latitude = 0, double longitude = 0}) {
  return Product(
    id: id,
    title: id,
    price: 'Rp1',
    location: '',
    imagePath: '',
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  const DeviceFix itb = DeviceFix(
    latitude: -6.8915,
    longitude: 107.6107,
    label: 'ITB Ganesha',
  );

  test('no viewer pin keeps the catalogue order', () {
    final List<Product> items = <Product>[_item('a'), _item('b')];
    expect(nearestFirst(items), items);
    expect(
      nearestFirst(
        items,
        fix: const DeviceFix(latitude: 0, longitude: 0, label: 'Lokasimu'),
      ),
      items,
    );
  });

  test('nearby pins come first and a far pin drops', () {
    final List<Product> items = <Product>[
      _item('jauh', latitude: -6.2, longitude: 106.8166),
      _item('tanpa-pin'),
      _item('dekat', latitude: -6.9, longitude: 107.6107),
    ];

    final List<Product> ordered = nearestFirst(items, fix: itb);

    expect(ordered.map((Product item) => item.id), <String>[
      'dekat',
      'tanpa-pin',
    ]);
    expect(distanceKm(-6.8915, 107.6107, -6.9, 107.6107), lessThan(2));
  });

  test('far pins stay, nearest first, when nothing is inside the radius', () {
    final List<Product> items = <Product>[
      _item('surabaya', latitude: -7.257, longitude: 112.752),
      _item('tanpa-pin'),
      _item('jakarta', latitude: -6.2, longitude: 106.8166),
    ];

    expect(
      nearestFirst(items, fix: itb).map((Product item) => item.id),
      <String>['jakarta', 'surabaya', 'tanpa-pin'],
    );
  });

  test('favorites keep far pins and still sort them', () {
    final List<Product> items = <Product>[
      _item('jauh', latitude: -6.2, longitude: 106.8166),
      _item('dekat', latitude: -6.9, longitude: 107.6107),
    ];

    expect(
      nearestFirst(
        items,
        fix: itb,
        keepFar: true,
      ).map((Product item) => item.id),
      <String>['dekat', 'jauh'],
    );
  });

  test('nominatim rows become short place names', () {
    final List<PlaceHit> hits = placeHitsFromNominatim(<Object?>[
      <String, Object?>{
        'name': 'Gedung A',
        'lat': '-6.891',
        'lon': '107.610',
        'address': <String, String>{'city': 'Bandung'},
      },
      <String, Object?>{'lat': 'nope', 'lon': '107'},
    ]);

    expect(hits, hasLength(1));
    expect(hits.single.label, 'Gedung A, Bandung');
    expect(hits.single.latitude, -6.891);
  });
}
