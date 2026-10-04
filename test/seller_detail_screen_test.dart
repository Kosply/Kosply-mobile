/// @title Seller detail tests
/// @notice Covers the seller profile, filters, and navigation from product
/// detail.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/screens/product_view_screen.dart';
import 'package:kosply_mobile/screens/seller_detail_screen.dart';
import 'package:kosply_mobile/widgets/product_grid.dart';
import 'package:kosply_mobile/widgets/seller_identity.dart';

/// @notice Seller detail behaviour checks.
/// @return void
void main() {
  Future<void> pumpSeller(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: SellerDetailScreen(sellerId: 'seller-1')),
    );
    await tester.pump();
  }

  testWidgets('seller detail shows identity, bio, heading, filters and cards', (
    WidgetTester tester,
  ) async {
    await pumpSeller(tester);

    expect(find.byType(SellerIdentity), findsOneWidget);
    expect(find.text('seller1'), findsWidgets);
    expect(find.text('aktif 5 menit lalu'), findsOneWidget);
    expect(find.textContaining('Lorem ipsum dolor sit amet'), findsOneWidget);
    expect(find.text('Chat penjual'), findsOneWidget);
    expect(find.text('Barang jualan'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Terbaru'), findsOneWidget);
    expect(find.text('Termurah'), findsOneWidget);
    expect(find.byType(ProductGrid), findsOneWidget);
    expect(find.text('Meja belajar lipat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping terbaru keeps the seller catalogue on screen', (
    WidgetTester tester,
  ) async {
    await pumpSeller(tester);

    await tester.tap(find.text('Terbaru'));
    await tester.pump();

    expect(find.byType(ProductGrid), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product detail seller row opens the seller screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const ProductViewScreen(productId: 'product-0'),
          onGenerateRoute: (RouteSettings settings) {
            if (settings.name == SellerDetailScreen.routeName) {
              return MaterialPageRoute<void>(
                builder: (_) =>
                    SellerDetailScreen(sellerId: settings.arguments! as String),
              );
            }
            return null;
          },
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.byType(SellerIdentity));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SellerIdentity));
    await tester.pumpAndSettle();

    expect(find.byType(SellerDetailScreen), findsOneWidget);
    expect(find.text('Barang jualan'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Chat penjual'), findsOneWidget);
  });
}
