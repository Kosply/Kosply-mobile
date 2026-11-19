/// @title Chat attach tests
/// @notice Plus sends the current pin or a photo immediately, with nothing
/// staged in the composer.
/// @author Kosply-mobile
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/camera/providers/camera_provider.dart';
import 'package:kosply_mobile/core/location/device_location.dart';
import 'package:kosply_mobile/data/uploads/upload_repository.dart';
import 'package:kosply_mobile/providers/catalog/listing_draft_provider.dart';
import 'package:kosply_mobile/providers/network/api_provider.dart';
import 'package:kosply_mobile/models/catalog/seller.dart';
import 'package:kosply_mobile/screens/main/inbox/chat_detail_screen.dart';
import 'package:kosply_mobile/widgets/common/chat/chat_composer.dart';
import 'package:kosply_mobile/widgets/common/chat/message_bubble.dart';

import 'helpers/fake_backend.dart';
import 'helpers/fake_listing_camera.dart';
import 'helpers/kosply_test_app.dart';

Future<void> _tick(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump();
}

void main() {
  testWidgets('plus sends the current location without a composer preview', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final FakeKosplyBackend backend = FakeKosplyBackend();

    await pumpKosplyApp(
      tester,
      const ChatDetailScreen(conversationId: 'seller-1'),
      backend: backend,
      location: const FixedDeviceLocation(
        'ITB Ganesha',
        latitude: -6.89,
        longitude: 107.61,
      ),
    );
    await _tick(tester);

    expect(find.byKey(const Key('chat-voice')), findsNothing);
    await tester.tap(find.byKey(const Key('chat-plus')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Kirim lokasi saat ini'), findsOneWidget);
    expect(find.text('Kirim foto'), findsOneWidget);

    await tester.tap(find.byKey(const Key('chat-attach-location')));
    await _tick(tester);
    await _tick(tester);

    final Map<String, dynamic> sent = FakeKosplyBackend.bodyOf(
      backend.calls('POST', '/api/conversations/seller-1/messages').last,
    );
    expect(sent['type'], 'LOCATION');
    expect(sent['latitude'], -6.89);
    expect(sent['longitude'], 107.61);
    expect(sent['locationLabel'], 'ITB Ganesha');
    expect(find.text('ITB Ganesha'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ChatComposer),
        matching: find.byKey(const Key('chat-location')),
      ),
      findsNothing,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('chat-input')))
          .controller!
          .text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('plus sends a photo immediately and leaves the field empty', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final FakeKosplyBackend backend = FakeKosplyBackend();

    await pumpKosplyApp(
      tester,
      const ChatDetailScreen(conversationId: 'seller-1'),
      backend: backend,
      overrides: [
        listingCameraFactoryProvider.overrideWithValue(FakeListingCamera.new),
        uploadRepositoryProvider.overrideWith(
          (ref) => UploadRepository(
            api: ref.watch(apiClientProvider),
            readBytes: (String path) async =>
                Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xD9]),
          ),
        ),
      ],
    );
    await _tick(tester);

    await tester.tap(find.byKey(const Key('chat-plus')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('chat-attach-photo')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Foto'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ktm-shutter')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(backend.calls('POST', '/api/uploads/images'), hasLength(1));
    final Map<String, dynamic> sent = FakeKosplyBackend.bodyOf(
      backend.calls('POST', '/api/conversations/seller-1/messages').last,
    );
    final String url = '${FakeKosplyBackend.origin}/uploads/photo1.jpg';
    expect(sent['type'], 'IMAGE');
    expect(sent['imageUrl'], url);
    expect(find.byKey(Key('chat-photo-$url')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ChatComposer),
        matching: find.byKey(Key('chat-photo-$url')),
      ),
      findsNothing,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('chat-input')))
          .controller!
          .text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long location label wraps inside the bubble', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    const String place =
        'Gang Melati Dalam IV, Sukajadi, Kota Bandung, Jawa Barat, Indonesia';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.centerRight,
            child: MessageBubble(
              text: '',
              mine: true,
              avatarPath: Seller.avatar,
              locationLabel: place,
              bubbleId: 'loc-1',
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('chat-location-loc-1')), findsOneWidget);
    expect(find.text(place), findsOneWidget);
    final double screen =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(
      tester.getTopRight(find.byType(MessageBubble)).dx,
      lessThanOrEqualTo(screen),
    );
    expect(tester.takeException(), isNull);
  });
}
