/// @title Inbox and chat tests
/// @notice Covers the inbox list, username search, unread fill, and chat
/// detail layout.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/screens/chat_detail_screen.dart';
import 'package:kosply_mobile/screens/inbox_screen.dart';

/// @notice Inbox and chat behaviour checks.
/// @return void
void main() {
  Future<void> pumpInbox(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: const InboxScreen(),
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == ChatDetailScreen.routeName) {
            return MaterialPageRoute<void>(
              builder: (_) =>
                  ChatDetailScreen(sellerId: settings.arguments! as String),
            );
          }
          return null;
        },
      ),
    );
    await tester.pump();
  }

  testWidgets('inbox shows search, category chips and conversation rows', (
    WidgetTester tester,
  ) async {
    await pumpInbox(tester);

    expect(find.text('Inbox'), findsNothing);
    expect(find.text('Cari username...'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Belum dibaca'), findsOneWidget);
    expect(find.text('Penjual'), findsOneWidget);
    expect(find.text('Pembeli'), findsOneWidget);
    expect(find.text('seller1'), findsOneWidget);
    expect(find.text('aktif 5 menit lalu'), findsNothing);
    expect(find.text('Meja masih available?'), findsOneWidget);
    expect(find.text('10:24'), findsOneWidget);
    expect(find.byKey(const Key('unread-seller-1')), findsOneWidget);
    expect(find.byKey(const Key('unread-seller-2')), findsNothing);
    expect(find.byIcon(Icons.tune), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inbox category chip filters conversations', (
    WidgetTester tester,
  ) async {
    await pumpInbox(tester);

    await tester.tap(find.text('Belum dibaca'));
    await tester.pump();

    expect(find.byKey(const Key('conversation-seller-1')), findsOneWidget);
    expect(find.byKey(const Key('conversation-seller-3')), findsOneWidget);
    expect(find.byKey(const Key('conversation-seller-2')), findsNothing);
    expect(find.byKey(const Key('conversation-seller-4')), findsNothing);
  });

  testWidgets('inbox search filters conversations by username', (
    WidgetTester tester,
  ) async {
    await pumpInbox(tester);

    await tester.enterText(
      find.byKey(const Key('inbox-username-search')),
      'seller3',
    );
    await tester.pump();

    expect(find.byKey(const Key('conversation-seller-3')), findsOneWidget);
    expect(find.byKey(const Key('conversation-seller-1')), findsNothing);
    expect(find.text('Oke, saya hold dulu ya'), findsOneWidget);
  });

  testWidgets('tapping a conversation opens chat detail', (
    WidgetTester tester,
  ) async {
    await pumpInbox(tester);

    await tester.tap(find.byKey(const Key('conversation-seller-1')));
    await tester.pumpAndSettle();

    expect(find.byType(ChatDetailScreen), findsOneWidget);
    expect(find.text('seller1'), findsWidgets);
    expect(find.text('aktif 5 menit lalu'), findsOneWidget);
    expect(find.byKey(const Key('chat-more')), findsOneWidget);
    expect(find.text('Hai seller1, barangnya masih ada?'), findsOneWidget);
    expect(find.text('Tulis pesan...'), findsOneWidget);
    expect(find.byKey(const Key('chat-plus')), findsOneWidget);
    expect(find.byKey(const Key('chat-voice')), findsOneWidget);
    expect(find.byKey(const Key('chat-input')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat detail renders photo, username, bubbles and composer', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: ChatDetailScreen(sellerId: 'seller-2')),
    );
    await tester.pump();

    expect(find.text('seller2'), findsOneWidget);
    expect(find.text('aktif 16 menit lalu'), findsOneWidget);
    expect(find.byKey(const Key('chat-more')), findsOneWidget);
    expect(find.text('Hai seller2, barangnya masih ada?'), findsOneWidget);
    expect(find.text('Bisa COD di Ganesha?'), findsOneWidget);
    expect(find.byKey(const Key('chat-plus')), findsOneWidget);
    expect(find.byKey(const Key('chat-voice')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
