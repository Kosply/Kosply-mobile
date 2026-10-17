/// @title SessionRepository
/// @notice Persists the signed-in session: tokens and session metadata only.
/// @dev Tokens and credentials never touch {PreferencesStore}; every field
/// lives in {SecureStore} under the `auth.*` keys. The Google sign-in is a
/// demo gateway until `google_sign_in` and the backend `/auth` route are
/// wired, so it returns a fixed campus account.
/// @author Kosply-mobile
library;

import 'dart:math';

import '../../core/storage/keys/storage_keys.dart';
import '../../core/storage/stores/secure_store.dart';
import '../../models/auth/auth_session.dart';

/// @title SessionRepository
/// @notice Reads and writes the session through {SecureStore}.
class SessionRepository {
  /// @notice Creates the repository.
  /// @param secure Keystore-backed secret store.
  /// @return A new {SessionRepository} instance.
  SessionRepository({required this.secure});

  /// @dev Keystore-backed secret store.
  final SecureStore secure;

  /// @dev Email returned by the demo Google gateway.
  static const String googleDemoEmail = 'fajar.arrizki@gmail.com';

  /// @dev Display name returned by the demo Google gateway.
  static const String googleDemoName = 'Fajar Arrizki';

  /// @notice Restores the stored session, if any.
  /// @dev Returns null when either token is missing, so a half-written
  /// session can never surface in the UI.
  /// @return The restored session, or null.
  Future<AuthSession?> restore() async {
    final String? access = await secure.read(StorageKeys.accessToken);
    final String? refresh = await secure.read(StorageKeys.refreshToken);
    if (access == null ||
        access.isEmpty ||
        refresh == null ||
        refresh.isEmpty) {
      return null;
    }
    return AuthSession(
      email: await secure.read(StorageKeys.authEmail) ?? '',
      displayName: await secure.read(StorageKeys.authDisplayName) ?? '',
      provider: _providerFrom(await secure.read(StorageKeys.authProvider)),
      accessToken: access,
      refreshToken: refresh,
      onboardingRequired:
          await secure.read(StorageKeys.authOnboarding) == '1',
    );
  }

  /// @notice Signs in with Google and stores the new session.
  /// @dev Demo gateway: a real build swaps this body for `google_sign_in`
  /// plus the backend `/auth/google` exchange. Because the Google account
  /// already carries email and name, onboarding skips those steps.
  /// @return The stored session.
  Future<AuthSession> signInWithGoogle() {
    return _persist(
      AuthSession(
        email: googleDemoEmail,
        displayName: googleDemoName,
        provider: AuthProvider.google,
        accessToken: _issueToken('google'),
        refreshToken: _issueToken('google-refresh'),
        onboardingRequired: true,
      ),
    );
  }

  /// @notice Signs in with an email address and stores the new session.
  /// @dev The password is verified by the backend once `/auth` is wired;
  /// it is never persisted on device.
  /// @param email Account email.
  /// @return The stored session.
  Future<AuthSession> signInWithEmail({required String email}) {
    return _persist(
      AuthSession(
        email: email,
        displayName: '',
        provider: AuthProvider.email,
        accessToken: _issueToken('email'),
        refreshToken: _issueToken('email-refresh'),
      ),
    );
  }

  /// @notice Clears the onboarding flag after the campus steps.
  /// @param session Current session.
  /// @return The session with `onboardingRequired` set to false.
  Future<AuthSession> markOnboarded(AuthSession session) async {
    await secure.write(StorageKeys.authOnboarding, '0');
    return session.copyWith(onboardingRequired: false);
  }

  /// @notice Removes every session key from the keystore.
  /// @return Future completing when the keys are gone.
  Future<void> signOut() async {
    await secure.delete(StorageKeys.accessToken);
    await secure.delete(StorageKeys.refreshToken);
    await secure.delete(StorageKeys.authEmail);
    await secure.delete(StorageKeys.authDisplayName);
    await secure.delete(StorageKeys.authProvider);
    await secure.delete(StorageKeys.authOnboarding);
  }

  /// @notice Writes every session field and returns it.
  /// @param session Session to persist.
  /// @return The stored session.
  Future<AuthSession> _persist(AuthSession session) async {
    await secure.write(StorageKeys.accessToken, session.accessToken);
    await secure.write(StorageKeys.refreshToken, session.refreshToken);
    await secure.write(StorageKeys.authEmail, session.email);
    await secure.write(StorageKeys.authDisplayName, session.displayName);
    await secure.write(StorageKeys.authProvider, session.provider.name);
    await secure.write(
      StorageKeys.authOnboarding,
      session.onboardingRequired ? '1' : '0',
    );
    return session;
  }

  /// @notice Builds a placeholder token for the demo gateway.
  /// @dev Shaped like the backend's opaque tokens; replaced wholesale when
  /// the auth API lands.
  /// @param scope Token family used in the prefix.
  /// @return The generated token.
  String _issueToken(String scope) {
    final int stamp = DateTime.now().microsecondsSinceEpoch;
    final int salt = Random().nextInt(0x7fffffff);
    return '$scope.$stamp.${salt.toRadixString(16)}';
  }

  /// @notice Maps a stored provider name back to the enum.
  /// @param raw Stored value, null when unset.
  /// @return The matching provider, email by default.
  AuthProvider _providerFrom(String? raw) {
    return raw == AuthProvider.google.name
        ? AuthProvider.google
        : AuthProvider.email;
  }
}
