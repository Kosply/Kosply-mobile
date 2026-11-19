/// @title Remaining integration
/// @notice Locks the phone routes that used to stop at the fake: AI stream
/// with chat approval, listing writes, catalogue events, notifications,
/// verification, reports, ticket close, and the chat stream.
/// @dev Apple login stays unwired. Nothing here places a phone call.
/// @author Kosply-mobile
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/network/api_exception.dart';
import 'package:kosply_mobile/data/account/verification_repository.dart';
import 'package:kosply_mobile/data/catalog/catalog_repository.dart';
import 'package:kosply_mobile/data/chat/ai_chat_repository.dart';
import 'package:kosply_mobile/models/chat/ai_turn.dart';
import 'package:kosply_mobile/data/notifications/notification_repository.dart';
import 'package:kosply_mobile/data/reports/report_repository.dart';
import 'package:kosply_mobile/providers/catalog/catalog_providers.dart';
import 'package:kosply_mobile/providers/chat/ai_chat_provider.dart';
import 'package:kosply_mobile/providers/inbox/inbox_providers.dart';
import 'package:kosply_mobile/providers/support/support_providers.dart';
import 'package:kosply_mobile/screens/main/home/home_screen.dart';

import 'helpers/fake_backend.dart';
import 'helpers/kosply_test_app.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

/// @notice Integration checks for the routes wired in this pass.
/// @return void
void main() {
  testWidgets('AI stream shows thinking and approves a chat action', (
    WidgetTester tester,
  ) async {
    _phone(tester);
    final FakeKosplyBackend backend = FakeKosplyBackend();
    backend.aiThinking = 'lagi mikir';
    backend.aiNeedsApproval = true;
    await pumpKosplyApp(tester, const HomeScreen(), backend: backend);

    await tester.tap(find.byKey(const Key('ai-fab')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('ai-input')), 'Tanya penjual');
    await tester.tap(find.byKey(const Key('ai-send')));
    for (int i = 0; i < 8; i++) {
      await tester.pump();
    }

    expect(find.text('Proses berpikir'), findsOneWidget);
    expect(find.text('lagi mikir'), findsNothing);
    await tester.ensureVisible(find.text('Proses berpikir'));
    await tester.tap(find.text('Proses berpikir'));
    await tester.pump();
    expect(find.text('lagi mikir'), findsOneWidget);
    expect(find.text('Preview pesan'), findsOneWidget);
    expect(find.text('Halo, barangnya masih ada?'), findsOneWidget);
    expect(find.text(AiChatRepository.approvalAsk), findsOneWidget);
    expect(find.text(AiChatRepository.approvalText), findsNothing);
    expect(find.byKey(const Key('ai-approve')), findsOneWidget);
    expect(find.byKey(const Key('ai-reject')), findsOneWidget);
    expect(find.textContaining('telepon'), findsNothing);
    expect(backend.calls('POST', '/api/ai/chat/stream'), isNotEmpty);
    expect(backend.calls('POST', '/api/ai/chat'), isEmpty);

    final Map<String, dynamic> sent = jsonDecode(
      backend.calls('POST', '/api/ai/chat/stream').last.body,
    ) as Map<String, dynamic>;
    expect(sent['message'], 'Tanya penjual');
    expect(
      backend.requests.where(
        (request) => request.url.path.contains('/api/ai/wait/'),
      ),
      isNotEmpty,
    );

    await tester.ensureVisible(find.byKey(const Key('ai-approve')));
    await tester.tap(find.byKey(const Key('ai-approve')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Disetujui.'), findsOneWidget);
    expect(find.text('Preview pesan'), findsNothing);
    expect(find.text(aiPendingText), findsNothing);
    expect(find.byKey(const Key('ai-approve')), findsNothing);
    final Map<String, dynamic> resume = jsonDecode(
      backend.calls('POST', '/api/ai/chat/resume').single.body,
    ) as Map<String, dynamic>;
    expect(resume['approve'], isTrue);
    expect(tester.takeException(), isNull);
  });

  test('AI stream returns the approval turn after thinking', () async {
    final FakeKosplyBackend backend = FakeKosplyBackend();
    backend.aiThinking = 'lagi mikir';
    backend.aiNeedsApproval = true;
    final ProviderContainer container = await seededContainer(backend: backend);
    addTearDown(container.dispose);
    final AiChatRepository repo = container.read(aiChatRepositoryProvider);
    final List<String> partials = <String>[];
    final AiTurn turn = await repo
        .ask(
          conversationId: 'thread-1',
          message: 'Tanya penjual',
          onPartial: (String thinking, String answer) {
            partials.add('$thinking|$answer');
          },
        )
        .timeout(const Duration(seconds: 5));
    expect(partials, <String>['lagi mikir|']);
    expect(turn.thinking, 'lagi mikir');
    expect(turn.needsApproval, isTrue);
    expect(turn.draft, 'Halo, barangnya masih ada?');
    expect(turn.answer, AiChatRepository.approvalAsk);
  });

  test('listing writes, events, inbox, and reports hit the backend', () async {
    final FakeKosplyBackend backend = FakeKosplyBackend();
    final ProviderContainer container = await seededContainer(backend: backend);
    final CatalogRepository catalog = container.read(catalogRepositoryProvider);

    final String id = await catalog.createListing(
      const NewListing(
        title: 'Lampu belajar',
        description: 'Lampu putih, masih nyala.',
        category: 'Elektronik',
        price: 45000,
        stock: 1,
        imageUrls: <String>['http://kosply.test/uploads/photo1.jpg'],
        locationLabel: 'Ganesha',
      ),
    );
    await catalog.updateListing(
      id,
      const NewListing(
        title: 'Lampu belajar LED',
        description: 'Lampu putih, masih nyala.',
        category: 'Elektronik',
        price: 40000,
        stock: 1,
        imageUrls: <String>['http://kosply.test/uploads/photo1.jpg'],
        locationLabel: 'Ganesha',
      ),
    );
    expect(backend.products[id]!['title'], 'Lampu belajar LED');
    expect(backend.products[id]!['price'], 40000);

    await catalog.recordEvent('product-0', 'CLICK', source: 'detail');
    expect(backend.analyticsEvents.single['type'], 'CLICK');
    expect(backend.analyticsEvents.single['recorded'], '1');

    final stats = await catalog.productStats(id);
    expect(stats.impressions, 0);
    await expectLater(
      catalog.productStats('product-0'),
      throwsA(
        isA<ApiException>().having(
          (ApiException error) => error.statusCode,
          'statusCode',
          403,
        ),
      ),
    );

    await catalog.archiveListing(id);
    expect(backend.products[id]!['status'], 'ARCHIVED');

    final NotificationRepository notes = container.read(
      notificationRepositoryProvider,
    );
    final inbox = await notes.list();
    expect(inbox.single.title, 'Pesan baru');
    expect(inbox.single.isRead, isFalse);
    await notes.markRead(inbox.single.id);
    expect(await notes.markAllRead(), 0);
    final Map<String, bool> prefs = await notes.preferences();
    expect(prefs['chat'], isTrue);
    expect(prefs['verification'], isTrue);
    expect(prefs.containsKey('newMessage'), isFalse);

    final verification = container.read(verificationRepositoryProvider);
    expect(await verification.mine(), isNull);
    final filed = await verification.submit(
      namaLengkap: 'Kamu',
      nim: '253140701111034',
      universitas: 'Universitas Indonesia',
      programStudi: 'S1 Teknik Informatika',
      ktmImageUrl: 'http://kosply.test/uploads/ktm.jpg',
    );
    expect(filed.isPending, isTrue);
    expect((await verification.mine())?.nim, '253140701111034');
    await expectLater(
      verification.submit(
        namaLengkap: 'Kamu',
        nim: '253140701111034',
        universitas: 'Universitas Indonesia',
        programStudi: 'S1 Teknik Informatika',
        ktmImageUrl: 'http://kosply.test/uploads/ktm.jpg',
      ),
      throwsA(
        isA<ApiException>().having(
          (ApiException error) => error.code,
          'code',
          'VERIFICATION_EXISTS',
        ),
      ),
    );

    final String reportNo = await container
        .read(reportRepositoryProvider)
        .file(
          reportedProductId: 'product-0',
          category: 'PENIPUAN',
          description: 'Foto tidak sesuai.',
        );
    expect(reportNo, startsWith('RPT-'));

    await container.read(supportRepositoryProvider).close('ticket-1');
    expect(backend.tickets['ticket-1']!['status'], 'CLOSED');

    await container.read(inboxRepositoryProvider).pullStream('seller-1');
    expect(
      backend.calls('GET', '/api/conversations/seller-1/stream'),
      isNotEmpty,
    );
    expect(
      await container.read(inboxRepositoryProvider).waitForMessages('seller-1'),
      isFalse,
    );
  });
}
