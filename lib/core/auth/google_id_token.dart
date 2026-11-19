/// @title GoogleIdTokenSource
/// @notice Gets a Google id token for `POST /api/auth/google`.
/// @dev The backend verifies the token against its web OAuth client id, so
/// the phone must request it with that id as `serverClientId`. Kept behind an
/// interface so widget tests never open the platform account picker.
/// @author Kosply-mobile
library;

import 'package:google_sign_in/google_sign_in.dart';

import '../network/api_config.dart';
import '../network/api_exception.dart';

/// @title GoogleIdTokenSource
/// @notice One Google sign-in, returning its id token.
abstract interface class GoogleIdTokenSource {
  /// @notice Opens the account picker and returns the id token.
  /// @dev Throws {ApiException} with `GOOGLE_NOT_CONFIGURED` when no client id
  /// was compiled in, and `GOOGLE_CANCELED` when the student backs out.
  /// @return The Google id token.
  Future<String> idToken();
}

/// @title DeviceGoogleIdTokenSource
/// @notice {GoogleIdTokenSource} backed by `google_sign_in`.
class DeviceGoogleIdTokenSource implements GoogleIdTokenSource {
  bool _initialized = false;

  @override
  Future<String> idToken() async {
    final String serverClientId = ApiConfig.googleServerClientId;
    if (serverClientId.isEmpty) {
      throw const ApiException(statusCode: 0, code: 'GOOGLE_NOT_CONFIGURED');
    }
    final GoogleSignIn signIn = GoogleSignIn.instance;
    if (!_initialized) {
      await signIn.initialize(serverClientId: serverClientId);
      _initialized = true;
    }
    try {
      final GoogleSignInAccount account = await signIn.authenticate();
      final String? token = account.authentication.idToken;
      if (token == null || token.isEmpty) {
        throw const ApiException(statusCode: 0, code: 'SOCIAL_AUTH_FAILED');
      }
      return token;
    } on GoogleSignInException catch (error) {
      throw ApiException(
        statusCode: 0,
        code: error.code == GoogleSignInExceptionCode.canceled
            ? 'GOOGLE_CANCELED'
            : 'SOCIAL_AUTH_FAILED',
        message: error.description ?? '',
      );
    }
  }
}
