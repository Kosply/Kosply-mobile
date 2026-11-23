/// @title Location label tests
/// @notice The home pill shows the device place, and the caption helper
/// joins a suburb with a city.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/location/device_location.dart';
import 'package:kosply_mobile/layouts/main_layout.dart';

import 'helpers/kosply_test_app.dart';

void main() {
  test('caption joins a suburb and a city', () {
    expect(
      captionFromParts(area: 'Ganesha', city: 'Bandung', name: 'ITB'),
      'Ganesha, Bandung',
    );
    expect(captionFromParts(area: 'Bandung', city: 'Bandung'), 'Bandung');
    expect(captionFromParts(), isNull);
  });

  testWidgets('the home pill asks once and shows the device place', (
    WidgetTester tester,
  ) async {
    await pumpKosplyApp(tester, const KosplyMainLayout());

    expect(
      tester.widget<Text>(find.byKey(const Key('location-label'))).data,
      'ITB Ganesha',
    );
  });
}
