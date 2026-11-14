/// @title Product camera tests
/// @notice Covers the listing photo camera: slots, shutter lock, Lanjut,
/// permission failure, and releasing the camera.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/camera/listing_camera.dart';
import 'package:kosply_mobile/core/camera/providers/camera_provider.dart';
import 'package:kosply_mobile/providers/catalog/listing_photos_provider.dart';
import 'package:kosply_mobile/screens/seller/product/add_product_screen.dart';
import 'package:kosply_mobile/screens/seller/product/product_camera_screen.dart';

import 'helpers/fake_listing_camera.dart';
import 'helpers/kosply_test_app.dart';

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
      routes: <String, WidgetBuilder>{
        AddProductScreen.routeName: (_) => const AddProductScreen(),
      },
      container: await seededContainer(
        overrides: [
          listingCameraFactoryProvider.overrideWithValue(() => camera),
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

  testWidgets('Lanjut opens the form and back keeps the photos', (
    WidgetTester tester,
  ) async {
    final FakeListingCamera camera = FakeListingCamera();
    await pumpCamera(tester, camera);

    await shoot(tester, 5);
    await tester.tap(find.byKey(const Key('product-camera-next')));
    await tester.pumpAndSettle();

    expect(find.byType(AddProductScreen), findsOneWidget);
    expect(find.text('Tambah barang'), findsOneWidget);
    expect(camera.isOpen, isFalse);

    Navigator.of(tester.element(find.byType(AddProductScreen))).pop();
    await tester.pumpAndSettle();

    expect(find.byType(ProductCameraScreen), findsOneWidget);
    expect(find.text('Foto 5/5'), findsOneWidget);
    expect(camera.isOpen, isTrue);
    expect(camera.opens, 2);
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
