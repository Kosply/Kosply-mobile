/// @title API config tests
/// @notice Checks that `.env` text becomes the origin and Google client id.
/// @author Kosply-mobile
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/network/api_config.dart';

/// @notice Env parsing checks.
/// @return void
void main() {
  test('env text sets the api url and google client id', () {
    final String url = ApiConfig.baseUrl;
    final String google = ApiConfig.googleServerClientId;
    addTearDown(() {
      ApiConfig.baseUrl = url;
      ApiConfig.googleServerClientId = google;
    });

    expect(
      parseEnv('# note\n\nKOSPLY_API_URL="http://192.168.100.98:3500/"\nEMPTY=\n'),
      <String, String>{'KOSPLY_API_URL': 'http://192.168.100.98:3500/'},
    );

    ApiConfig.apply('''
# phone on the LAN
KOSPLY_API_URL="http://192.168.100.98:3500/"
GOOGLE_SERVER_CLIENT_ID='client-id'
''');

    expect(ApiConfig.baseUrl, 'http://192.168.100.98:3500');
    expect(ApiConfig.googleServerClientId, 'client-id');
  });
}
