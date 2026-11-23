/// @title UI bridge tests
/// @notice The agent reply can move the phone: open a product, filter the
/// catalogue, and ignore a callback Flutter does not implement.
/// @author Kosply-mobile
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kosply_mobile/core/ui_bridge/catalog_filter.dart';
import 'package:kosply_mobile/core/ui_bridge/ui_bridge.dart';
import 'package:kosply_mobile/core/ui_bridge/ui_commands.dart';
import 'package:kosply_mobile/layouts/main_layout.dart';
import 'package:kosply_mobile/models/chat/ai_turn.dart';
import 'package:kosply_mobile/screens/seller/product/product_view_screen.dart';
import 'package:kosply_mobile/widgets/product/card/product_card.dart';

import 'helpers/fake_backend.dart';
import 'helpers/fixtures/placeholder_catalog.dart';
import 'helpers/kosply_test_app.dart';

void _setPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// @notice Callback parsing and on-screen execution.
/// @return void
void main() {
  test('a turn keeps named callbacks and drops a blank one', () {
    final AiTurn turn = AiTurn.fromJson(<String, dynamic>{
      'answer': 'Ini mejanya.',
      'callbacks': <Object?>[
        <String, dynamic>{
          'callback': 'open_product',
          'args': <String, dynamic>{'productId': 'product-0'},
        },
        <String, dynamic>{'callback': ''},
        'skip',
      ],
    });

    expect(turn.answer, 'Ini mejanya.');
    expect(turn.callbacks, hasLength(1));
    expect(turn.callbacks.single.name, 'open_product');
    expect(turn.callbacks.single.args['productId'], 'product-0');
  });

  test('the catalogue filter matches the title and the price cap', () {
    final meja = PlaceholderCatalog.productAt(0);
    final rice = PlaceholderCatalog.productAt(2);
    const CatalogFilter byName = CatalogFilter(query: 'rice');
    const CatalogFilter byPrice = CatalogFilter(maxPrice: 100000);

    expect(byName.allows(rice), isTrue);
    expect(byName.allows(meja), isFalse);
    expect(byPrice.allows(rice), isTrue);
    expect(byPrice.allows(meja), isFalse);
  });

  testWidgets('callbacks filter the feed, highlight a card, and open it', (
    WidgetTester tester,
  ) async {
    _setPhone(tester);
    final FakeKosplyBackend backend = FakeKosplyBackend();
    backend.aiCallbacks = <Map<String, dynamic>>[
      <String, dynamic>{
        'callback': 'show_toast',
        'args': <String, dynamic>{'message': 'Dari AI.'},
      },
    ];
    final container = await pumpKosplyApp(
      tester,
      const KosplyMainLayout(),
      backend: backend,
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == ProductViewScreen.routeName) {
          return MaterialPageRoute<void>(
            builder: (_) =>
                ProductViewScreen(productId: settings.arguments! as String),
          );
        }
        return null;
      },
    );

    await tester.pump();
    final Map<String, Object?>? uiState = container
        .read(uiBridgeProvider)
        .toJson();
    expect(uiState?['screen'], 'home');

    container.read(uiCommandsProvider.notifier).enqueue(<UiCallback>[
      const UiCallback(name: 'buy_now'),
      const UiCallback(
        name: 'apply_filter',
        args: <String, Object?>{'query': 'rice'},
      ),
    ]);
    await tester.pump();
    await tester.pump();

    expect(find.text('Rice cooker 1.8L'), findsWidgets);
    expect(find.text('Meja belajar lipat'), findsNothing);
    expect(find.text('Kipas angin meja'), findsNothing);
    expect(find.byType(ProductViewScreen), findsNothing);

    container.read(uiCommandsProvider.notifier).enqueue(<UiCallback>[
      const UiCallback(name: 'clear_filter'),
      const UiCallback(
        name: 'highlight',
        args: <String, Object?>{'productId': 'product-0'},
      ),
    ]);
    await tester.pump();
    await tester.pump();

    expect(find.text('Meja belajar lipat'), findsWidgets);
    expect(
      tester
          .widgetList<ProductCard>(find.byType(ProductCard))
          .where(
            (ProductCard card) =>
                card.title == 'Meja belajar lipat' && card.highlighted,
          ),
      isNotEmpty,
    );

    container.read(uiCommandsProvider.notifier).enqueue(<UiCallback>[
      const UiCallback(
        name: 'open_product',
        args: <String, Object?>{'product_id': 'product-0'},
      ),
    ]);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ProductViewScreen), findsOneWidget);
    expect(find.text('Chat penjual'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1600));

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'Buka meja');
    await tester.tap(find.byKey(const Key('ai-send')));
    await tester.pump();
    await tester.pump();

    final List<http.Request> calls = backend.calls(
      'POST',
      '/api/ai/chat/stream',
    );
    expect(calls, isNotEmpty);
    final Map<String, dynamic> body =
        jsonDecode(calls.last.body) as Map<String, dynamic>;
    expect(body['message'], 'Buka meja');
    expect(body['ui_state'], isA<Map<String, dynamic>>());
    expect(find.text('Dari AI.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
