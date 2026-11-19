/// @title Product camera tests
/// @notice Covers the listing photo camera: slots, shutter lock, Lanjut,
/// permission failure, and releasing the camera.
/// @author Kosply-mobile
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/camera/listing_camera.dart';
import 'package:kosply_mobile/core/camera/providers/camera_provider.dart';
import 'package:kosply_mobile/data/uploads/upload_repository.dart';
import 'package:kosply_mobile/models/catalog/listing_photos.dart';
import 'package:kosply_mobile/providers/catalog/listing_draft_provider.dart';
import 'package:kosply_mobile/providers/catalog/listing_photos_provider.dart';
import 'package:kosply_mobile/providers/network/api_provider.dart';
import 'package:kosply_mobile/screens/seller/product/add_product_screen.dart';
import 'package:kosply_mobile/screens/seller/product/product_camera_screen.dart';

import 'helpers/fake_backend.dart';
import 'helpers/fake_listing_camera.dart';
import 'helpers/kosply_test_app.dart';

/// @notice Five captured photos, so Pasang barang can upload without the camera.
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

/// @notice Product camera behaviour checks.
/// @return void
void main() {
  const Key shutter = Key('product-camera-shutter');

  Future<ProviderContainer> pumpCamera(
    WidgetTester tester,
    FakeListingCamera camera,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    return pumpKosplyApp(
      tester,
      const ProductCameraScreen(),
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == AddProductScreen.routeName) {
          return MaterialPageRoute<bool?>(
            settings: settings,
            builder: (_) => const AddProductScreen(),
          );
        }
        return null;
      },
      container: await seededContainer(
        overrides: [
          listingCameraFactoryProvider.overrideWithValue(() => camera),
          // Captures are fake paths. The form still uploads through the API.
          uploadRepositoryProvider.overrideWith(
            (ref) => UploadRepository(
              api: ref.watch(apiClientProvider),
              readBytes: (String path) async =>
                  Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xD9]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> shoot(WidgetTester tester, int times) async {
    for (int i = 0; i < times; i++) {
      await tester.tap(find.byKey(shutter));
      await tester.pump();
    }
  }

  TextButton next(WidgetTester tester) {
    return tester.widget<TextButton>(
      find.byKey(const Key('product-camera-next')),
    );
  }

  testWidgets('camera opens with five empty slots and Lanjut disabled', (
    WidgetTester tester,
  ) async {
    final FakeListingCamera camera = FakeListingCamera();
    await pumpCamera(tester, camera);

    expect(camera.opens, 1);
    expect(find.byKey(const Key('fake-camera-preview')), findsOneWidget);
    expect(find.text('Foto 0/5'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(next(tester).onPressed, isNull);
    for (int i = 0; i < 5; i++) {
      expect(find.byKey(Key('product-camera-slot-$i')), findsOneWidget);
    }
    expect(find.byKey(const Key('product-camera-flash')), findsOneWidget);
    expect(find.byKey(const Key('product-camera-flip')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('five shots enable Lanjut and lock the shutter', (
    WidgetTester tester,
  ) async {
    final FakeListingCamera camera = FakeListingCamera();
    await pumpCamera(tester, camera);

    await shoot(tester, 4);
    expect(find.text('Foto 4/5'), findsOneWidget);
    expect(next(tester).onPressed, isNull);

    await shoot(tester, 1);
    expect(find.text('Foto 5/5'), findsOneWidget);
    expect(next(tester).onPressed, isNotNull);

    await shoot(tester, 1);
    expect(camera.shots, 5);
  });

  testWidgets('removing a photo frees its slot for the next shot', (
    WidgetTester tester,
  ) async {
    final FakeListingCamera camera = FakeListingCamera();
    final ProviderContainer container = await pumpCamera(tester, camera);

    await shoot(tester, 3);
    await tester.tap(find.byKey(const Key('product-camera-remove-1')));
    await tester.pump();

    expect(find.text('Foto 2/5'), findsOneWidget);
    expect(find.byKey(const Key('product-camera-remove-1')), findsNothing);

    await shoot(tester, 1);

    expect(find.text('Foto 3/5'), findsOneWidget);
    expect(container.read(listingPhotosProvider).slots, <String?>[
      'fake/photo-1.jpg',
      'fake/photo-4.jpg',
      'fake/photo-3.jpg',
      null,
      null,
    ]);
  });

  testWidgets('the form opens the camera and Lanjut brings the photos back', (
    WidgetTester tester,
  ) async {
    final FakeListingCamera camera = FakeListingCamera();
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(
      tester,
      const AddProductScreen(),
      routes: <String, WidgetBuilder>{
        ProductCameraScreen.routeName: (_) => const ProductCameraScreen(),
      },
      container: await seededContainer(
        overrides: [
          listingCameraFactoryProvider.overrideWithValue(() => camera),
          uploadRepositoryProvider.overrideWith(
            (Ref ref) => UploadRepository(
              api: ref.watch(apiClientProvider),
              readBytes: (String path) async =>
                  Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xD9]),
            ),
          ),
        ],
      ),
    );

    expect(find.text('Menunggu AI'), findsNothing);
    expect(find.text('Kami lagi memproses'), findsNothing);

    await tester.tap(find.byKey(const Key('add-product-photo')));
    await tester.pumpAndSettle();

    expect(find.byType(ProductCameraScreen), findsOneWidget);
    await shoot(tester, 5);
    await tester.tap(find.byKey(const Key('product-camera-next')));
    await tester.pumpAndSettle();

    expect(find.byType(AddProductScreen), findsOneWidget);
    expect(find.text('Foto (5/5)'), findsOneWidget);
    expect(find.text('Cover'), findsOneWidget);
    expect(find.byKey(const Key('add-product-photo-0')), findsOneWidget);
    expect(camera.isOpen, isFalse);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('add-product-edit-photos')));
    await tester.pumpAndSettle();

    expect(find.byType(ProductCameraScreen), findsOneWidget);
    expect(find.text('Foto 5/5'), findsOneWidget);
    expect(camera.isOpen, isTrue);
    expect(camera.opens, 2);
  });

  testWidgets('pasang barang uploads photos and posts the typed fields', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final FakeKosplyBackend backend = FakeKosplyBackend();
    await pumpKosplyApp(
      tester,
      const AddProductScreen(),
      backend: backend,
      overrides: [
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

    await tester.enterText(
      find.byKey(const Key('add-product-title')),
      'Meja lipat',
    );
    await tester.enterText(
      find.byKey(const Key('add-product-price')),
      '150000',
    );
    await tester.enterText(
      find.byKey(const Key('add-product-location')),
      'Gedung A',
    );
    await tester.enterText(
      find.byKey(const Key('add-product-description')),
      'Kaki masih lurus, minus dus.',
    );
    await tester.ensureVisible(find.byKey(const Key('add-product-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-product-category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pakaian').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-product-submit')));
    await tester.pumpAndSettle();

    expect(backend.calls('POST', '/api/ai/chat'), isEmpty);
    expect(backend.calls('POST', '/api/uploads/images'), hasLength(5));
    final Map<String, dynamic> sent = FakeKosplyBackend.bodyOf(
      backend.calls('POST', '/api/products').single,
    );
    expect(sent['title'], 'Meja lipat');
    expect(sent['description'], 'Kaki masih lurus, minus dus.');
    expect(sent['category'], 'Pakaian');
    expect(sent['price'], 150000);
    expect(sent['stock'], 1);
    expect(sent['locationLabel'], 'Gedung A');
    expect(sent['imageUrls'], hasLength(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('flash and flip buttons drive the camera', (
    WidgetTester tester,
  ) async {
    final FakeListingCamera camera = FakeListingCamera();
    await pumpCamera(tester, camera);

    await tester.tap(find.byKey(const Key('product-camera-flash')));
    await tester.pump();
    expect(camera.flash, isTrue);

    await tester.tap(find.byKey(const Key('product-camera-flip')));
    await tester.pump();
    expect(camera.switches, 1);
  });

  testWidgets('flip button hides when there is only one lens direction', (
    WidgetTester tester,
  ) async {
    await pumpCamera(tester, FakeListingCamera(canSwitchLens: false));

    expect(find.byKey(const Key('product-camera-flip')), findsNothing);
  });

  testWidgets('denied permission explains itself and blocks the shutter', (
    WidgetTester tester,
  ) async {
    final FakeListingCamera camera = FakeListingCamera(
      failure: ListingCameraFailure.denied,
    );
    await pumpCamera(tester, camera);

    expect(find.textContaining('Izin kamera ditolak'), findsOneWidget);
    expect(find.byKey(const Key('product-camera-flash')), findsNothing);

    await shoot(tester, 1);
    expect(camera.shots, 0);

    await tester.tap(find.byKey(const Key('product-camera-retry')));
    await tester.pump();
    expect(camera.opens, 2);
  });

  testWidgets('camera is released in the background and restarted on return', (
    WidgetTester tester,
  ) async {
    final FakeListingCamera camera = FakeListingCamera();
    await pumpCamera(tester, camera);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(camera.isOpen, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(camera.isOpen, isTrue);
    expect(camera.opens, 2);
  });
}
