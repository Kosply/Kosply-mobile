/// @title Favorite, analytic, and add-product tests
/// @notice Covers heart-to-favorite, seller metrics, and the stacked add-product form.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/providers/favorites_provider.dart';
import 'package:kosply_mobile/screens/add_product_screen.dart';
import 'package:kosply_mobile/screens/analytic_screen.dart';
import 'package:kosply_mobile/screens/favorite_screen.dart';
import 'package:kosply_mobile/screens/product_view_screen.dart';
import 'package:kosply_mobile/widgets/product_grid.dart';
import 'package:kosply_mobile/widgets/seller_app_bar.dart';

void _setPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2100);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// @notice Favorite, analytic, and new-product behaviour checks.
/// @return void
void main() {
  testWidgets('empty favorite shows search, category chip, and empty copy', (
    WidgetTester tester,
  ) async {
    _setPhone(tester);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: FavoriteScreen())),
    );
    await tester.pump();

    expect(find.text('Favorite'), findsWidgets);
    expect(find.text('Cari favorite...'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Belum ada barang favorite.'), findsOneWidget);
    expect(find.byType(ProductGrid), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('heart on product detail adds the item to favorite', (
    WidgetTester tester,
  ) async {
    _setPhone(tester);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const ProductViewScreen(productId: 'product-0'),
          routes: <String, WidgetBuilder>{
            FavoriteScreen.routeName: (_) => const FavoriteScreen(),
          },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('product-favorite')));
    await tester.pump();

    FavoriteScreen.push(tester.element(find.byType(ProductViewScreen)));
    await tester.pumpAndSettle();

    expect(find.byType(FavoriteScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FavoriteScreen),
        matching: find.text('Meja belajar lipat'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(FavoriteScreen),
        matching: find.byType(ProductGrid),
      ),
      findsOneWidget,
    );
    expect(find.text('Belum ada barang favorite.'), findsNothing);
  });

  testWidgets('favorite search and category chips filter saved items', (
    WidgetTester tester,
  ) async {
    _setPhone(tester);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: FavoriteScreen())),
    );
    await tester.pump();

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(FavoriteScreen)),
    );
    container.read(favoritesProvider.notifier).toggle('product-0');
    container.read(favoritesProvider.notifier).toggle('product-1');
    await tester.pump();

    expect(find.text('Meja belajar lipat'), findsOneWidget);
    expect(find.text('Kipas angin meja'), findsOneWidget);
    expect(find.text('Kamar'), findsOneWidget);
    expect(find.text('Dapur Kos'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('favorite-search')), 'belajar');
    await tester.pump();

    expect(find.text('Meja belajar lipat'), findsOneWidget);
    expect(find.text('Kipas angin meja'), findsNothing);

    await tester.enterText(find.byKey(const Key('favorite-search')), '');
    await tester.pump();
    await tester.tap(find.text('Kamar'));
    await tester.pump();

    expect(find.text('Meja belajar lipat'), findsOneWidget);
    expect(find.text('Kipas angin meja'), findsNothing);
  });

  testWidgets(
    'analytic shows seller bar, metric cards, and catalogue sections',
    (WidgetTester tester) async {
      _setPhone(tester);

      await tester.pumpWidget(const MaterialApp(home: AnalyticScreen()));
      await tester.pump();

      expect(find.byType(SellerAppBar), findsOneWidget);
      expect(find.text('seller1'), findsOneWidget);
      expect(find.text('Views'), findsOneWidget);
      expect(find.text('1.284'), findsOneWidget);
      expect(find.text('Favorite'), findsOneWidget);
      expect(find.text('46'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('Terjual'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Trading product kamu'), findsOneWidget);
      expect(find.byType(ProductGrid), findsWidgets);

      final Finder scroll = find.byKey(const Key('analytic-scroll'));
      await tester.dragUntilVisible(
        find.text('Paling diminati'),
        scroll,
        const Offset(0, -280),
      );
      await tester.dragUntilVisible(
        find.text('Hampir habis'),
        scroll,
        const Offset(0, -280),
      );
      await tester.dragUntilVisible(
        find.text('Baru dilihat'),
        scroll,
        const Offset(0, -280),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('new product uses stacked labels above fields', (
    WidgetTester tester,
  ) async {
    _setPhone(tester);

    await tester.pumpWidget(const MaterialApp(home: AddProductScreen()));
    await tester.pump();

    expect(find.text('Tambah barang'), findsOneWidget);
    expect(find.text('Nama barang'), findsOneWidget);
    expect(find.text('Harga'), findsOneWidget);
    expect(find.text('Lokasi'), findsOneWidget);
    expect(find.text('Kuantitas'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Deskripsi'), findsOneWidget);
    expect(find.text('Pasang barang'), findsOneWidget);
    expect(find.text('Title'), findsNothing);
    expect(find.byKey(const Key('add-product-photo')), findsOneWidget);
    expect(find.byKey(const Key('add-product-title')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
