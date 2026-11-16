/// @title Profile photo tests
/// @notice Verifies the profile editor uploads a camera shot and saves its URL.
/// @author Kosply-mobile
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/camera/providers/camera_provider.dart';
import 'package:kosply_mobile/data/uploads/upload_repository.dart';
import 'package:kosply_mobile/providers/catalog/listing_draft_provider.dart';
import 'package:kosply_mobile/providers/network/api_provider.dart';
import 'package:kosply_mobile/screens/settings/profile/profile_setting_screen.dart';

import 'helpers/fake_backend.dart';
import 'helpers/fake_listing_camera.dart';
import 'helpers/kosply_test_app.dart';

/// @notice Profile photo checks.
/// @return void
void main() {
  testWidgets('a new profile photo is uploaded and saved as its URL', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2100);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final FakeKosplyBackend backend = FakeKosplyBackend();

    await pumpKosplyApp(
      tester,
      const ProfileSettingScreen(),
      backend: backend,
      overrides: [
        listingCameraFactoryProvider.overrideWithValue(FakeListingCamera.new),
        // The capture is a fake path. The upload still goes through the API.
        uploadRepositoryProvider.overrideWith(
          (ref) => UploadRepository(
            api: ref.watch(apiClientProvider),
            readBytes: (String path) async =>
                Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xD9]),
          ),
        ),
      ],
    );

    await tester.tap(find.byKey(const Key('profile-photo')));
    await tester.pumpAndSettle();
    expect(find.text('Foto profil'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ktm-shutter')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSettingScreen), findsOneWidget);
    expect(backend.calls('POST', '/api/uploads/images'), hasLength(1));

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    final Map<String, dynamic> saved = FakeKosplyBackend.bodyOf(
      backend.calls('PATCH', '/api/users/me').last,
    );
    expect(saved['photo'], '${FakeKosplyBackend.origin}/uploads/photo1.jpg');
    expect(backend.users[FakeKosplyBackend.meId]!['photo'], saved['photo']);
  });
}
