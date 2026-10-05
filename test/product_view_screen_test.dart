/// @title Product detail tests
/// @notice Checks the cleaned-up product view layout.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/screens/product_view_screen.dart';
import 'package:kosply_mobile/widgets/seller_identity.dart';

/// @notice Product detail layout checks.
/// @return void
void main() {
  Future<void> pumpDetail(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProductViewScreen(productId: 'product-0')),
      ),
    );
    await tester.pump();
  }

  testWidgets('product detail shows title, seller, info and chat bar', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester);

    expect(find.text('Meja belajar lipat'), findsWidgets);
    expect(find.text('Rp.375.000'), findsOneWidget);
    expect(find.text('Deskripsi'), findsOneWidget);
    expect(find.text('Kuantitas'), findsOneWidget);
    expect(find.text('Lokasi'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Rekomendasi'), findsOneWidget);
    expect(find.text('Chat penjual'), findsOneWidget);
    expect(find.text('seller1'), findsOneWidget);
    await tester.ensureVisible(find.byType(SellerIdentity));
    await tester.pumpAndSettle();
    expect(find.text('aktif 5 menit lalu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat bar stays pinned below the scrolling body', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester);

    final Finder chat = find.text('Chat penjual');
    expect(chat, findsOneWidget);

    await tester.drag(
      find.byKey(const Key('product-detail-scroll')),
      const Offset(0, -800),
    );
    await tester.pump();

    expect(find.text('Chat penjual'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
