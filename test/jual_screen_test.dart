/// @title Jual screen tests
/// @notice Covers the seller dashboard: identity, search actions, and add
/// product.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/models/account_mode.dart';
import 'package:kosply_mobile/providers/account_mode_provider.dart';
import 'package:kosply_mobile/screens/add_product_screen.dart';
import 'package:kosply_mobile/screens/analytic_screen.dart';
import 'package:kosply_mobile/screens/jual_screen.dart';
import 'package:kosply_mobile/widgets/product_grid.dart';
import 'package:kosply_mobile/widgets/seller_identity.dart';

/// @notice Jual dashboard behaviour checks.
/// @return void
void main() {
  Future<void> pumpJual(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const JualScreen(),
          routes: <String, WidgetBuilder>{
            AddProductScreen.routeName: (_) => const AddProductScreen(),
            AnalyticScreen.routeName: (_) => const AnalyticScreen(),
          },
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> setSeller(WidgetTester tester) async {
    ProviderScope.containerOf(tester.element(find.byType(JualScreen)))
        .read(accountModeProvider.notifier)
        .setMode(AccountMode.seller);
    await tester.pump();
  }

  testWidgets('jual shows identity, bio, search and listing actions', (
    WidgetTester tester,
  ) async {
    await pumpJual(tester);

    expect(find.byType(SellerIdentity), findsOneWidget);
    expect(find.text('seller1'), findsOneWidget);
    expect(find.textContaining('Lorem ipsum dolor sit amet'), findsOneWidget);
    expect(find.text('Cari barang jualan...'), findsOneWidget);
    expect(find.byKey(const Key('jual-analytic')), findsNothing);
    expect(find.byKey(const Key('jual-add')), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.byType(ProductGrid), findsOneWidget);
    expect(find.text('Meja belajar lipat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('jual search filters the seller catalogue', (
    WidgetTester tester,
  ) async {
    await pumpJual(tester);

    await tester.enterText(find.byKey(const Key('jual-search')), 'Meja');
    await tester.pump();

    expect(find.text('Meja belajar lipat'), findsOneWidget);
    expect(find.text('Lampu belajar LED'), findsNothing);
  });

  testWidgets('analytic button opens the analytic screen', (
    WidgetTester tester,
  ) async {
    await pumpJual(tester);
    await setSeller(tester);

    await tester.tap(find.byKey(const Key('jual-analytic')));
    await tester.pumpAndSettle();

    expect(find.byType(AnalyticScreen), findsOneWidget);
    expect(find.text('Views'), findsOneWidget);
    expect(find.text('Trading product kamu'), findsOneWidget);
  });

  testWidgets('plus button opens add product', (WidgetTester tester) async {
    await pumpJual(tester);

    await tester.tap(find.byKey(const Key('jual-add')));
    await tester.pumpAndSettle();

    expect(find.byType(AddProductScreen), findsOneWidget);
    expect(find.text('Tambah barang'), findsOneWidget);
    expect(find.text('Nama barang'), findsOneWidget);
    expect(find.text('Deskripsi'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Pasang barang'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
