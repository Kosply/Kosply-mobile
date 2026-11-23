/// @title Search catalogue tests
/// @notice Typing on Home or Search does not reload the feed. Enter opens a
/// results screen with a back button, the query, and the matching cards.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/layouts/main_layout.dart';
import 'package:kosply_mobile/screens/main/search/search_catalog_screen.dart';

import 'helpers/kosply_test_app.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2100);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> _submit(WidgetTester tester, String query) async {
  await tester.enterText(find.byKey(const Key('catalog-search')), query);
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// @notice Finder limited to the results route.
/// @dev The shell stays mounted underneath an opaque route, so a page-wide
/// [find.text] still sees the Home and Search cards.
Finder _onResults(Finder finder) {
  return find.descendant(
    of: find.byType(SearchCatalogScreen),
    matching: finder,
  );
}

void main() {
  testWidgets('home keeps its cards until Enter opens the catalogue', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    await pumpKosplyApp(tester, const KosplyMainLayout());

    await tester.enterText(find.byKey(const Key('catalog-search')), 'rice');
    await tester.pump();

    expect(find.byType(SearchCatalogScreen), findsNothing);
    expect(find.byKey(const Key('search-filter')), findsNothing);
    expect(find.text('Meja belajar lipat'), findsWidgets);
    expect(find.text('Rice cooker 1.8L'), findsWidgets);

    await _submit(tester, 'rice');

    expect(find.byType(SearchCatalogScreen), findsOneWidget);
    expect(find.byKey(const Key('search-catalog-back')), findsOneWidget);
    expect(find.byKey(const Key('search-filter')), findsOneWidget);
    expect(_onResults(find.text('Rice cooker 1.8L')), findsOneWidget);
    expect(_onResults(find.text('Meja belajar lipat')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('search-catalog-input')),
      'zzz',
    );
    await tester.pump();
    expect(_onResults(find.text('Rice cooker 1.8L')), findsOneWidget);
    expect(find.byKey(const Key('search-catalog-empty')), findsNothing);

    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(find.byKey(const Key('search-catalog-empty')), findsOneWidget);
    expect(_onResults(find.text('Rice cooker 1.8L')), findsNothing);

    await tester.tap(find.byKey(const Key('search-catalog-back')));
    await tester.pump();
    // The page transition is 450ms. The route stays mounted until it ends.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SearchCatalogScreen), findsNothing);
    expect(find.text('Meja belajar lipat'), findsWidgets);
  });

  testWidgets('the search tab opens the same catalogue on Enter', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    await pumpKosplyApp(tester, const KosplyMainLayout());

    await tester.tap(find.text('Search'));
    await tester.pump();

    expect(find.text('Dibuka terakhir'), findsOneWidget);
    expect(find.byKey(const Key('search-opened-empty')), findsOneWidget);
    expect(find.byKey(const Key('search-filter')), findsNothing);
    expect(find.text('Karpet lantai 2x1'), findsNothing);
    await tester.enterText(find.byKey(const Key('catalog-search')), 'kipas');
    await tester.pump();
    expect(find.text('Dibuka terakhir'), findsOneWidget);
    expect(find.byKey(const Key('search-opened-empty')), findsOneWidget);
    expect(find.byType(SearchCatalogScreen), findsNothing);

    await _submit(tester, 'kipas');

    expect(find.byType(SearchCatalogScreen), findsOneWidget);
    expect(find.byKey(const Key('search-filter')), findsOneWidget);
    expect(_onResults(find.text('Kipas angin meja')), findsOneWidget);
    expect(_onResults(find.text('Dibuka terakhir')), findsNothing);
    expect(_onResults(find.text('Karpet lantai 2x1')), findsNothing);
    expect(_onResults(find.text('Meja belajar lipat')), findsNothing);
  });
}
