/// @title Home AI overlay tests
/// @notice Covers the brain circle, search-width composer, chat overlay,
/// minimize arrows, history replace, and the Home history list.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/layouts/main_layout.dart';
import 'package:kosply_mobile/screens/main/home/home_screen.dart';
import 'package:kosply_mobile/screens/seller/product/product_view_screen.dart';
import 'package:kosply_mobile/widgets/common/search/searchbar.dart';

import 'helpers/kosply_test_app.dart';

void _setPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2100);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> _pumpHome(WidgetTester tester) async {
  _setPhone(tester);
  await pumpKosplyApp(tester, const HomeScreen());
  await tester.pump();
}

/// @notice Home AI overlay behaviour checks.
/// @return void
void main() {
  testWidgets('home shows a centered AI circle and a chat history list', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    expect(find.byKey(const Key('ai-fab')), findsOneWidget);
    expect(find.byKey(const Key('ai-composer')), findsNothing);
    expect(tester.getSize(find.byKey(const Key('ai-fab'))).width, 48);
    final Rect fab = tester.getRect(find.byKey(const Key('ai-fab')));
    final double width =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(fab.center.dx, greaterThan(width * 0.7));

    await tester.dragUntilVisible(
      find.text('Cari meja belajar'),
      find.byKey(const Key('home-scroll')),
      const Offset(0, -280),
    );
    expect(find.text('Chat history'), findsOneWidget);
    expect(find.text('Cari meja belajar'), findsOneWidget);
    expect(find.text('Harga kipas angin'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the circle expands a search-width composer', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();

    expect(find.byKey(const Key('ai-fab')), findsNothing);
    expect(find.byKey(const Key('ai-composer')), findsOneWidget);
    expect(find.byKey(const Key('ai-voice')), findsNothing);
    expect(find.byKey(const Key('ai-input')), findsOneWidget);
    expect(find.byKey(const Key('ai-history')), findsOneWidget);
    expect(find.byKey(const Key('ai-send')), findsOneWidget);
    expect(find.text('Tanya Kosply AI...'), findsOneWidget);

    expect(
      tester.getSize(find.byKey(const Key('ai-composer'))).width,
      tester.getSize(find.byType(KosplySearchbar)).width,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('send opens a chat overlay with copy and ulangi', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'Halo AI');
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();

    expect(find.byKey(const Key('ai-panel')), findsOneWidget);
    expect(find.text('Halo AI'), findsWidgets);
    expect(find.textContaining('Lorem ipsum'), findsWidgets);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Ulangi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('panel arrow minimizes to title and expands again', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'Halo AI');
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();

    expect(find.text('Copy'), findsWidgets);

    await tester.tap(find.byKey(const Key('ai-panel-toggle')));
    await tester.pump();

    expect(find.text('Halo AI'), findsOneWidget);
    expect(find.text('Copy'), findsNothing);
    expect(find.textContaining('Lorem ipsum'), findsNothing);
    expect(find.byKey(const Key('ai-composer')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('ai-panel'))).width,
      tester.getSize(find.byKey(const Key('ai-composer'))).width,
    );

    await tester.tap(find.byKey(const Key('ai-panel-toggle')));
    await tester.pump();

    expect(find.text('Copy'), findsWidgets);
    expect(find.textContaining('Lorem ipsum'), findsWidgets);
  });

  testWidgets('chat history replaces the chat overlay', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'Halo AI');
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('ai-history')));
    await tester.pump();

    expect(find.text('chat history'), findsOneWidget);
    expect(find.text('Copy'), findsNothing);
    expect(find.byKey(const Key('ai-history-row-ai-1')), findsOneWidget);
    expect(find.text('Cari meja belajar'), findsWidgets);

    await tester.tap(find.byKey(const Key('ai-history-row-ai-1')));
    await tester.pump();

    expect(find.text('chat history'), findsNothing);
    expect(find.text('Cari meja belajar'), findsWidgets);
    expect(find.text('Copy'), findsWidgets);
  });

  testWidgets('home history row opens that thread in the overlay', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    await tester.dragUntilVisible(
      find.byKey(const Key('home-ai-history-ai-1')),
      find.byKey(const Key('home-scroll')),
      const Offset(0, -280),
    );
    await tester.tap(find.byKey(const Key('home-ai-history-ai-1')));
    await tester.pump();

    expect(find.byKey(const Key('ai-composer')), findsOneWidget);
    expect(find.byKey(const Key('ai-panel')), findsOneWidget);
    expect(find.text('Cari meja belajar'), findsWidgets);
    expect(find.text('Copy'), findsWidgets);
    expect(find.text('Ulangi'), findsWidgets);
  });

  testWidgets('ulangi appends another prompt and lorem reply', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'Halo AI');
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();

    expect(find.text('Copy'), findsOneWidget);

    await tester.ensureVisible(find.text('Ulangi').first);
    await tester.pump();
    await tester.tap(find.text('Ulangi').first);
    await tester.pump();

    expect(find.text('Copy'), findsNWidgets(2));
    expect(find.text('Ulangi'), findsNWidgets(2));
    expect(find.text('Halo AI'), findsWidgets);
  });

  testWidgets('tapping outside closes the overlay', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester);

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'Halo AI');
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();

    expect(find.byKey(const Key('ai-panel')), findsOneWidget);
    expect(find.byKey(const Key('ai-composer')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ai-dismiss')));
    await tester.pump();

    expect(find.byKey(const Key('ai-fab')), findsOneWidget);
    expect(find.byKey(const Key('ai-composer')), findsNothing);
    expect(find.byKey(const Key('ai-panel')), findsNothing);
  });

  testWidgets('the AI control stays on every tab and on a product', (
    WidgetTester tester,
  ) async {
    _setPhone(tester);
    await pumpKosplyApp(tester, const KosplyMainLayout());

    expect(find.byKey(const Key('ai-fab')), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Dibuka terakhir'), findsOneWidget);
    expect(find.byKey(const Key('ai-fab')), findsOneWidget);

    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-fab')), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ai-fab')), findsOneWidget);

    final BuildContext shell = tester.element(find.byType(KosplyMainLayout));
    unawaited(
      Navigator.of(shell).push(
        MaterialPageRoute<void>(
          builder: (_) => const ProductViewScreen(productId: 'product-0'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Meja belajar lipat'), findsWidgets);
    expect(find.byKey(const Key('ai-fab')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an open composer stays open when the screen changes', (
    WidgetTester tester,
  ) async {
    _setPhone(tester);
    await pumpKosplyApp(tester, const KosplyMainLayout());

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'jangan hilang');
    await tester.pump();

    expect(find.byKey(const Key('ai-composer')), findsOneWidget);
    expect(find.byKey(const Key('ai-fab')), findsNothing);

    await tester.tap(find.text('Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('jangan hilang'), findsOneWidget);
    expect(find.byKey(const Key('ai-composer')), findsOneWidget);
    expect(find.byKey(const Key('ai-fab')), findsNothing);

    final BuildContext shell = tester.element(find.byType(KosplyMainLayout));
    unawaited(
      Navigator.of(shell).push(
        MaterialPageRoute<void>(
          builder: (_) => const ProductViewScreen(productId: 'product-0'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Meja belajar lipat'), findsWidgets);
    expect(find.text('jangan hilang'), findsOneWidget);
    expect(find.byKey(const Key('ai-composer')), findsOneWidget);
    expect(find.byKey(const Key('ai-fab')), findsNothing);
  });
}
