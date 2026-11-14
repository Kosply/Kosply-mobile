/// @title Jual screen tests
/// @notice Covers the seller dashboard: identity, search actions, and add
/// product.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/camera/providers/camera_provider.dart';
import 'package:kosply_mobile/models/account/account_mode.dart';
import 'package:kosply_mobile/providers/account/account_mode_provider.dart';
import 'package:kosply_mobile/screens/seller/product/add_product_screen.dart';
import 'package:kosply_mobile/screens/seller/product/product_camera_screen.dart';
import 'package:kosply_mobile/screens/seller/analytic/analytic_screen.dart';
import 'package:kosply_mobile/screens/main/jual/jual_screen.dart';
import 'package:kosply_mobile/widgets/product/grid/product_grid.dart';
import 'package:kosply_mobile/widgets/seller/identity/seller_identity.dart';

import 'helpers/fake_listing_camera.dart';
import 'helpers/kosply_test_app.dart';

/// @notice Jual dashboard behaviour checks.
/// @return void
void main() {
  Future<ProviderContainer> pumpJual(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    return pumpKosplyApp(
      tester,
      const JualScreen(),
      routes: <String, WidgetBuilder>{
        ProductCameraScreen.routeName: (_) => const ProductCameraScreen(),
        AddProductScreen.routeName: (_) => const AddProductScreen(),
        AnalyticScreen.routeName: (_) => const AnalyticScreen(),
      },
      container: await seededContainer(
        overrides: [
          listingCameraFactoryProvider.overrideWithValue(FakeListingCamera.new),
        ],
      ),
    );
  }

  Future<void> setSeller(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    container.read(accountModeProvider.notifier).setMode(AccountMode.seller);
    await tester.pump();
  }

  testWidgets('jual shows identity, bio, search and listing actions', (
    WidgetTester tester,
  ) async {
    await pumpJual(tester);

    expect(find.byType(SellerIdentity), findsOneWidget);
    expect(find.text('Kamu'), findsOneWidget);
    expect(
      find.textContaining('Lagi beres-beres kos'),
      findsOneWidget,
    );
    expect(find.text('Cari barang jualan...'), findsOneWidget);
    expect(find.byKey(const Key('jual-analytic')), findsNothing);
    expect(find.byKey(const Key('jual-add')), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    // This student has not published a listing, so the shelf stays empty.
    expect(find.text('Belum ada barang di filter ini.'), findsOneWidget);
    expect(find.byType(ProductGrid), findsNothing);
    expect(find.text('Meja belajar lipat'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('jual search filters the seller catalogue', (
    WidgetTester tester,
  ) async {
    await pumpJual(tester);

    await tester.enterText(find.byKey(const Key('jual-search')), 'Meja');
    await tester.pump();

    // The signed-in shelf is empty; other sellers' listings stay off it.
    expect(find.text('Meja belajar lipat'), findsNothing);
    expect(find.text('Lampu belajar LED'), findsNothing);
  });

  testWidgets('analytic button opens the analytic screen', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpJual(tester);
    await setSeller(tester, container);

    await tester.tap(find.byKey(const Key('jual-analytic')));
    await tester.pumpAndSettle();

    expect(find.byType(AnalyticScreen), findsOneWidget);
    expect(find.text('Views'), findsOneWidget);
    expect(find.text('Trading product kamu'), findsOneWidget);
  });

  testWidgets('plus button opens the product camera and back returns', (
    WidgetTester tester,
  ) async {
    await pumpJual(tester);

    await tester.tap(find.byKey(const Key('jual-add')));
    await tester.pumpAndSettle();

    expect(find.byType(ProductCameraScreen), findsOneWidget);
    expect(find.text('Foto 0/5'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('product-camera-back')));
    await tester.pumpAndSettle();

    expect(find.byType(ProductCameraScreen), findsNothing);
    expect(find.byType(JualScreen), findsOneWidget);
  });
}
