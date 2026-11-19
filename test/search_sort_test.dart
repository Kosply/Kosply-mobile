/// @title Search sort sheet
/// @notice The catalogue filter offers termurah, termahal, terdekat, and
/// terjauh.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/screens/main/search/search_catalog_screen.dart';

import 'helpers/kosply_test_app.dart';

Finder _onResults(Finder finder) {
  return find.descendant(
    of: find.byType(SearchCatalogScreen),
    matching: finder,
  );
}

double _top(WidgetTester tester, String title) {
  return tester.getTopLeft(_onResults(find.text(title))).dy;
}

void main() {
  testWidgets('the search sheet sorts by price and has no category list', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 3000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpKosplyApp(tester, const SearchCatalogScreen(query: 'lipat'));

    expect(_onResults(find.text('Meja belajar lipat')), findsOneWidget);
    expect(_onResults(find.text('Jemuran baju lipat')), findsOneWidget);
    expect(_onResults(find.text('Kursi lipat kampus')), findsOneWidget);

    await tester.tap(find.byKey(const Key('search-filter')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('search-sort-termurah')), findsOneWidget);
    expect(find.byKey(const Key('search-sort-termahal')), findsOneWidget);
    expect(find.byKey(const Key('search-sort-terdekat')), findsOneWidget);
    expect(find.byKey(const Key('search-sort-terjauh')), findsOneWidget);
    expect(find.text('Termurah'), findsOneWidget);
    expect(find.text('Termahal'), findsOneWidget);
    expect(find.text('Terdekat'), findsOneWidget);
    expect(find.text('Terjauh'), findsOneWidget);
    expect(find.text('Kategori'), findsNothing);
    expect(find.byKey(const Key('search-filter-Kamar')), findsNothing);

    await tester.tap(find.byKey(const Key('search-sort-termurah')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      _top(tester, 'Jemuran baju lipat'),
      lessThan(_top(tester, 'Kursi lipat kampus')),
    );
    expect(
      _top(tester, 'Meja belajar lipat'),
      lessThan(_top(tester, 'Kursi lipat kampus')),
    );

    await tester.tap(find.byKey(const Key('search-filter')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('search-sort-termahal')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      _top(tester, 'Kursi lipat kampus'),
      lessThan(_top(tester, 'Jemuran baju lipat')),
    );
    expect(
      _top(tester, 'Meja belajar lipat'),
      lessThan(_top(tester, 'Jemuran baju lipat')),
    );
    expect(tester.takeException(), isNull);
  });
}
