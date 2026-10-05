/// @title Help desk and contact support tests
/// @notice Covers the FAQ dropdown, ticket inbox, create ticket, and ticket
/// chat.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/screens/contact_support_screen.dart';
import 'package:kosply_mobile/screens/create_ticket_screen.dart';
import 'package:kosply_mobile/screens/help_desk_screen.dart';
import 'package:kosply_mobile/screens/ticket_detail_screen.dart';

/// @notice Support behaviour checks.
/// @return void
void main() {
  Future<void> setView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('help desk expands a topic to show its answer', (
    WidgetTester tester,
  ) async {
    await setView(tester);
    await tester.pumpWidget(const MaterialApp(home: HelpDeskScreen()));
    await tester.pump();

    expect(find.text('Help desk'), findsOneWidget);
    expect(find.text('Barang tidak sesuai deskripsi'), findsOneWidget);
    expect(find.text('Lapor penipuan'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsNothing);
    expect(
      find.textContaining('Foto dan cek barang saat ketemu'),
      findsNothing,
    );

    await tester.tap(find.text('Barang tidak sesuai deskripsi'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Foto dan cek barang saat ketemu'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Lapor penipuan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lapor penipuan'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Foto dan cek barang saat ketemu'),
      findsNothing,
    );
    expect(find.textContaining('Jangan lanjutkan pembayaran'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contact support shows search, chips and ticket rows', (
    WidgetTester tester,
  ) async {
    await setView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: const ContactSupportScreen(),
        routes: <String, WidgetBuilder>{
          CreateTicketScreen.routeName: (_) => const CreateTicketScreen(),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == TicketDetailScreen.routeName) {
            return MaterialPageRoute<void>(
              builder: (_) =>
                  TicketDetailScreen(ticketId: settings.arguments! as String),
            );
          }
          return null;
        },
      ),
    );
    await tester.pump();

    expect(find.text('Contact support'), findsOneWidget);
    expect(find.text('Cari ticket...'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Barang tidak sesuai deskripsi'), findsOneWidget);
    expect(find.byKey(const Key('ticket-unread-ticket-1')), findsOneWidget);
    expect(find.byKey(const Key('ticket-create')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contact support filters tickets by Close', (
    WidgetTester tester,
  ) async {
    await setView(tester);
    await tester.pumpWidget(const MaterialApp(home: ContactSupportScreen()));
    await tester.pump();

    await tester.tap(find.text('Close'));
    await tester.pump();

    expect(find.byKey(const Key('ticket-ticket-3')), findsOneWidget);
    expect(find.byKey(const Key('ticket-ticket-1')), findsNothing);
  });

  testWidgets('contact support search filters tickets by title', (
    WidgetTester tester,
  ) async {
    await setView(tester);
    await tester.pumpWidget(const MaterialApp(home: ContactSupportScreen()));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('ticket-search')), 'penipuan');
    await tester.pump();

    expect(find.byKey(const Key('ticket-ticket-4')), findsOneWidget);
    expect(find.byKey(const Key('ticket-ticket-1')), findsNothing);
  });

  testWidgets('tapping a ticket opens chat with username and active line', (
    WidgetTester tester,
  ) async {
    await setView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: const ContactSupportScreen(),
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == TicketDetailScreen.routeName) {
            return MaterialPageRoute<void>(
              builder: (_) =>
                  TicketDetailScreen(ticketId: settings.arguments! as String),
            );
          }
          return null;
        },
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('ticket-ticket-1')));
    await tester.pumpAndSettle();

    expect(find.byType(TicketDetailScreen), findsOneWidget);
    expect(find.text('Kosply Support'), findsOneWidget);
    expect(find.text('aktif sekarang'), findsOneWidget);
    expect(find.byKey(const Key('chat-more')), findsOneWidget);
    expect(find.text('Kategori masalah'), findsNothing);
    expect(find.byKey(const Key('ticket-topic-dropdown')), findsNothing);
    expect(
      find.textContaining('Hai, terima kasih sudah menghubungi Kosply'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('ticket-plus')), findsOneWidget);
    expect(find.byKey(const Key('ticket-voice')), findsOneWidget);
    expect(find.byKey(const Key('ticket-input')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('plus button opens create ticket with help desk dropdown', (
    WidgetTester tester,
  ) async {
    await setView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: const ContactSupportScreen(),
        routes: <String, WidgetBuilder>{
          CreateTicketScreen.routeName: (_) => const CreateTicketScreen(),
        },
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('ticket-create')));
    await tester.pumpAndSettle();

    expect(find.byType(CreateTicketScreen), findsOneWidget);
    expect(find.text('Buat ticket'), findsOneWidget);
    expect(find.text('Kategori masalah'), findsOneWidget);
    expect(find.byKey(const Key('create-ticket-dropdown')), findsOneWidget);
    expect(find.text('Kirim ticket'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
