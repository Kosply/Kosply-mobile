/// @title Location suggestions
/// @notice The add-product field starts from GPS and posts the pin of the
/// place the seller picks.
/// @author Kosply-mobile
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/location/device_location.dart';
import 'package:kosply_mobile/core/location/place_search.dart';
import 'package:kosply_mobile/data/uploads/upload_repository.dart';
import 'package:kosply_mobile/models/catalog/listing_photos.dart';
import 'package:kosply_mobile/providers/catalog/listing_draft_provider.dart';
import 'package:kosply_mobile/providers/catalog/listing_photos_provider.dart';
import 'package:kosply_mobile/providers/location/location_label_provider.dart';
import 'package:kosply_mobile/providers/network/api_provider.dart';
import 'package:kosply_mobile/screens/seller/product/add_product_screen.dart';

import 'helpers/fake_backend.dart';
import 'helpers/kosply_test_app.dart';

class _FullPhotos extends ListingPhotosNotifier {
  @override
  ListingPhotos build() {
    ListingPhotos photos = ListingPhotos.empty();
    for (int i = 0; i < ListingPhotos.required; i++) {
      photos = photos.withPhoto('shot-$i.jpg');
    }
    return photos;
  }
}

class _CampusSearch extends PlaceSearch {
  const _CampusSearch();

  @override
  Future<List<PlaceHit>> search(
    String query, {
    double? nearLatitude,
    double? nearLongitude,
  }) async {
    if (!query.toLowerCase().contains('ganesha')) {
      return const <PlaceHit>[];
    }
    return const <PlaceHit>[
      PlaceHit(
        label: 'Ganesha, Bandung',
        latitude: -6.8915,
        longitude: 107.6107,
      ),
    ];
  }
}

void main() {
  testWidgets('typing a place shows a suggestion and the pin is posted', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final FakeKosplyBackend backend = FakeKosplyBackend();
    await pumpKosplyApp(
      tester,
      const AddProductScreen(),
      backend: backend,
      overrides: [
        deviceLocationProvider.overrideWithValue(
          const FixedDeviceLocation(
            'ITB Ganesha',
            latitude: -6.8915,
            longitude: 107.6107,
          ),
        ),
        placeSearchProvider.overrideWithValue(const _CampusSearch()),
        listingPhotosProvider.overrideWith(_FullPhotos.new),
        uploadRepositoryProvider.overrideWith(
          (Ref ref) => UploadRepository(
            api: ref.watch(apiClientProvider),
            readBytes: (String path) async =>
                Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xD9]),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('add-product-location')))
          .controller
          ?.text,
      'ITB Ganesha',
    );

    await tester.enterText(
      find.byKey(const Key('add-product-location')),
      'ganesha',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Ganesha, Bandung'), findsOneWidget);
    await tester.tap(find.byKey(const Key('location-suggestion-0')));
    await tester.pumpAndSettle();
    expect(find.text('Ganesha, Bandung'), findsOneWidget);
    expect(find.byKey(const Key('location-suggestion-0')), findsNothing);

    await tester.enterText(find.byKey(const Key('add-product-title')), 'Meja');
    await tester.enterText(
      find.byKey(const Key('add-product-price')),
      '150000',
    );
    await tester.enterText(
      find.byKey(const Key('add-product-description')),
      'Masih utuh.',
    );
    await tester.ensureVisible(find.byKey(const Key('add-product-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-product-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pakaian').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-product-submit')));
    await tester.pumpAndSettle();

    final Map<String, dynamic> sent = FakeKosplyBackend.bodyOf(
      backend.calls('POST', '/api/products').single,
    );
    expect(sent['locationLabel'], 'Ganesha, Bandung');
    expect(sent['latitude'], -6.8915);
    expect(sent['longitude'], 107.6107);
    expect(tester.takeException(), isNull);
  });
}
