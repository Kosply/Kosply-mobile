/// @title Home AI overlay tests
/// @notice Covers the brain circle, search-width composer, chat overlay,
/// minimize arrows, history replace, and the Home history list.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/screens/home_screen.dart';
import 'package:kosply_mobile/screens/search_screen.dart';
import 'package:kosply_mobile/widgets/searchbar.dart';

void _setPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2100);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> _pumpHome(WidgetTester tester) async {
  _setPhone(tester);
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: HomeScreen())),
  );
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

    await tester.dragUntilVisible(
      find.text('Chat history'),
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
    expect(find.byKey(const Key('ai-voice')), findsOneWidget);
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
    expect(find.text('Copy'), findsNWidgets(2));
    expect(find.text('Ulangi'), findsNWidgets(2));
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

    expect(find.text('Copy'), findsNWidgets(2));

    await tester.ensureVisible(find.text('Ulangi').first);
    await tester.pump();
    await tester.tap(find.text('Ulangi').first);
    await tester.pump();

    expect(find.text('Copy'), findsNWidgets(4));
    expect(find.text('Ulangi'), findsNWidgets(4));
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

  testWidgets('search screen does not show the AI overlay', (
    WidgetTester tester,
  ) async {
    _setPhone(tester);
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SearchScreen())),
    );
    await tester.pump();

    expect(find.byKey(const Key('ai-fab')), findsNothing);
    expect(find.byKey(const Key('ai-composer')), findsNothing);
  });
}
