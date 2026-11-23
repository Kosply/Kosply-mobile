/// @title Form preview, screen move, and home banner
/// @notice The seller form is previewed before Setujui writes it, a screen
/// callback leaves Home, and the home banner is tall enough to hold a CTA.
/// @author Kosply-mobile
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/ui_bridge/catalog_filter.dart';
import 'package:kosply_mobile/data/chat/ai_chat_repository.dart';
import 'package:kosply_mobile/data/uploads/upload_repository.dart';
import 'package:kosply_mobile/layouts/main_layout.dart';
import 'package:kosply_mobile/models/catalog/listing_photos.dart';
import 'package:kosply_mobile/models/chat/ai_turn.dart';
import 'package:kosply_mobile/providers/catalog/listing_draft_provider.dart';
import 'package:kosply_mobile/providers/catalog/listing_photos_provider.dart';
import 'package:kosply_mobile/providers/chat/ai_chat_provider.dart';
import 'package:kosply_mobile/providers/network/api_provider.dart';
import 'package:kosply_mobile/screens/main/home/home_screen.dart';

import 'helpers/fake_backend.dart';
import 'helpers/kosply_test_app.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// @notice One captured listing photo, so the AI turn can upload it.
class _OnePhoto extends ListingPhotosNotifier {
  @override
  ListingPhotos build() => ListingPhotos.empty().withPhoto('shot.jpg');
}

/// @notice Form preview, navigation, and banner checks.
/// @return void
void main() {
  test('a form interrupt previews the four fields', () async {
    final FakeKosplyBackend backend = FakeKosplyBackend();
    backend.aiNeedsApproval = true;
    backend.aiFormFill = <String, Object>{
      'title': 'Meja belajar',
      'price': 85000,
      'description': 'Meja lipat, kaki masih kuat.',
      'category': 'Furnitur',
    };
    final ProviderContainer container = await seededContainer(backend: backend);
    addTearDown(container.dispose);
    final AiTurn turn = await container
        .read(aiChatRepositoryProvider)
        .ask(conversationId: 'thread-form', message: 'isi formnya')
        .timeout(const Duration(seconds: 5));
    expect(turn.needsApproval, isTrue);
    expect(turn.proposal?.title, 'Meja belajar');
    expect(turn.proposal?.price, 85000);
    expect(turn.proposal?.category, 'Furnitur');
    expect(turn.answer, AiChatRepository.approvalFill);
    expect(turn.draft, isEmpty);
  });

  testWidgets('Setujui writes the preview into the add-product form', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    final FakeKosplyBackend backend = FakeKosplyBackend();
    backend.aiNeedsApproval = true;
    backend.aiFormFill = <String, Object>{
      'title': 'Meja belajar',
      'price': 85000,
      'description': 'Meja lipat, kaki masih kuat.',
      'category': 'Furnitur',
    };
    await pumpKosplyApp(tester, const KosplyMainLayout(), backend: backend);

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'isi formnya');
    await tester.tap(find.byKey(const Key('ai-send')));
    for (int i = 0; i < 8; i++) {
      await tester.pump();
    }

    expect(find.text('Preview barang'), findsOneWidget);
    expect(find.text('Meja belajar'), findsOneWidget);
    expect(find.text('Rp85.000'), findsOneWidget);
    expect(find.text('Furnitur'), findsOneWidget);
    expect(find.text('Meja lipat, kaki masih kuat.'), findsOneWidget);
    expect(find.text(AiChatRepository.approvalFill), findsOneWidget);
    expect(find.text('Preview pesan'), findsNothing);
    expect(find.byKey(const Key('add-product-title')), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('ai-approve')));
    await tester.tap(find.byKey(const Key('ai-approve')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Preview barang'), findsNothing);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('add-product-title')))
          .controller
          ?.text,
      'Meja belajar',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('add-product-price')))
          .controller
          ?.text,
      '85000',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('add-product-description')))
          .controller
          ?.text,
      'Meja lipat, kaki masih kuat.',
    );
    expect(find.text('Furnitur'), findsOneWidget);
    expect(find.text('Pasang barang'), findsOneWidget);
    expect(backend.calls('POST', '/api/products'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tolak leaves the add-product form untouched', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    final FakeKosplyBackend backend = FakeKosplyBackend();
    backend.aiNeedsApproval = true;
    backend.aiFormFill = <String, Object>{
      'title': 'Meja belajar',
      'price': 85000,
      'description': 'Meja lipat, kaki masih kuat.',
      'category': 'Furnitur',
    };
    await pumpKosplyApp(tester, const KosplyMainLayout(), backend: backend);

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'isi formnya');
    await tester.tap(find.byKey(const Key('ai-send')));
    for (int i = 0; i < 8; i++) {
      await tester.pump();
    }
    await tester.ensureVisible(find.byKey(const Key('ai-reject')));
    await tester.tap(find.byKey(const Key('ai-reject')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Ditolak.'), findsOneWidget);
    expect(find.text('Preview barang'), findsNothing);
    expect(find.byKey(const Key('add-product-title')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('open_screen search leaves Home for the search tab', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    final FakeKosplyBackend backend = FakeKosplyBackend();
    backend.aiCallbacks = <Map<String, dynamic>>[
      <String, dynamic>{
        'callback': 'open_screen',
        'args': <String, dynamic>{'screen': 'search'},
      },
    ];
    await pumpKosplyApp(tester, const KosplyMainLayout(), backend: backend);
    expect(find.byKey(const Key('home-banner')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'buka search');
    await tester.tap(find.byKey(const Key('ai-send')));
    for (int i = 0; i < 8; i++) {
      await tester.pump();
    }

    expect(find.text('Dibuka terakhir'), findsOneWidget);
    expect(find.byKey(const Key('home-banner')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a captured photo is uploaded and sent for the model to see', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    final FakeKosplyBackend backend = FakeKosplyBackend();
    await pumpKosplyApp(
      tester,
      const HomeScreen(),
      backend: backend,
      overrides: [
        listingPhotosProvider.overrideWith(_OnePhoto.new),
        uploadRepositoryProvider.overrideWith(
          (Ref ref) => UploadRepository(
            api: ref.watch(apiClientProvider),
            readBytes: (String path) async =>
                Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xD9]),
          ),
        ),
      ],
    );

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'lihat fotonya');
    await tester.tap(find.byKey(const Key('ai-send')));
    for (int i = 0; i < 8; i++) {
      await tester.pump();
    }

    expect(backend.calls('POST', '/api/uploads/images'), isNotEmpty);
    final Map<String, dynamic> sent = jsonDecode(
      backend.calls('POST', '/api/ai/chat/stream').last.body,
    ) as Map<String, dynamic>;
    expect(sent['see_photos'], isTrue);
    expect(sent['imageUrls'], hasLength(1));
    expect(sent['imageUrls'][0], contains('/uploads/'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the home banner is taller and its copy is inset', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    final ProviderContainer container = await pumpKosplyApp(
      tester,
      const HomeScreen(),
    );
    await tester.pump();

    final Rect banner = tester.getRect(find.byKey(const Key('home-banner')));
    final Rect copy = tester.getRect(
      find.text('Meja, buku, dan peralatan kos dari mahasiswa di sekitarmu.'),
    );
    expect(banner.height, greaterThanOrEqualTo(188));
    expect(copy.left - banner.left, greaterThanOrEqualTo(24));
    expect(banner.right - copy.right, greaterThanOrEqualTo(24));
    expect(find.text('Cari barang'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-banner-cta')));
    await tester.pump();
    expect(container.read(catalogSearchFocusProvider).hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });
}
