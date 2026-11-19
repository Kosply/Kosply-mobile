/// @title SessionRepository
/// @notice Signs in against the backend and persists the resulting session.
/// @dev Every route here is `/api/auth/*` (`postman/specs/tables/auth.md`).
/// Tokens and credentials never touch {PreferencesStore}; every field lives
/// in {SecureStore} under the `auth.*` keys. The password is sent once and
/// never stored.
/// @author Kosply-mobile
library;

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/json_read.dart';
import '../../core/storage/keys/storage_keys.dart';
import '../../core/storage/stores/secure_store.dart';
import '../../models/auth/auth_session.dart';

/// @title SessionRepository
/// @notice Auth API calls plus keystore persistence of the session.
class SessionRepository {
  /// @notice Creates the repository.
  /// @param secure Keystore-backed secret store.
  /// @param api Backend client; auth routes are called without a token.
  /// @return A new {SessionRepository} instance.
  SessionRepository({required this.secure, required this.api});

  /// @dev Keystore-backed secret store.
  final SecureStore secure;

  /// @dev Backend client.
  final ApiClient api;

  /// @notice Restores the stored session, if any.
  /// @return The restored session, or null.
  Future<AuthSession?> restore() => restoreFrom(secure);

  /// @notice Restores a session straight from the keystore.
  /// @dev Static so `main` can restore before any provider (and so before an
  /// {ApiClient}) exists. Returns null when either token is missing, so a
  /// half-written session can never surface in the UI.
  /// @param secure Keystore-backed secret store.
  /// @return The restored session, or null.
  static Future<AuthSession?> restoreFrom(SecureStore secure) async {
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
      onboardingRequired: await secure.read(StorageKeys.authOnboarding) == '1',
      userId: await secure.read(StorageKeys.authUserId) ?? '',
      username: await secure.read(StorageKeys.authUsername) ?? '',
      role: await secure.read(StorageKeys.authRole) ?? 'BUYER',
    );
  }

  /// @notice Signs in with email and password.
  /// @param email Account email.
  /// @param password Account password, sent once and never stored.
  /// @return The stored session.
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> json = await api.post(
      '/api/auth/login',
      body: <String, String>{'email': email, 'password': password},
      auth: false,
    );
    return _persist(_sessionFrom(json, AuthProvider.email));
  }

  /// @notice Creates a buyer account and signs it in.
  /// @param email Account email.
  /// @param username Marketplace handle.
  /// @param name Display name.
  /// @param password At least 6 characters.
  /// @param universitas Campus name.
  /// @param programStudi Study programme.
  /// @param code Mailbox proof from {requestEmailCode}. Omitted only for
  /// addresses the server already exempts.
  /// @return The stored session.
  Future<AuthSession> register({
    required String email,
    required String username,
    required String name,
    required String password,
    required String universitas,
    required String programStudi,
    String? code,
  }) async {
    final Map<String, dynamic> json = await api.post(
      '/api/auth/register',
      body: <String, String>{
        'email': email,
        'username': username,
        'name': name,
        'password': password,
        'universitas': universitas,
        'programStudi': programStudi,
        if (code != null && code.isNotEmpty) 'code': code,
      },
      auth: false,
    );
    return _persist(_sessionFrom(json, AuthProvider.email));
  }

  /// @notice Exchanges a Google id token for a Kosply session.
  /// @dev New Google accounts come back with `onboardingRequired`, and the
  /// shortened registration form completes them through `PATCH /users/me`.
  /// @param idToken Token from `google_sign_in`.
  /// @return The stored session.
  Future<AuthSession> signInWithGoogle(String idToken) async {
    final Map<String, dynamic> json = await api.post(
      '/api/auth/google',
      body: <String, String>{'idToken': idToken},
      auth: false,
    );
    return _persist(_sessionFrom(json, AuthProvider.google));
  }

  /// @notice Rotates the token pair.
  /// @dev The server consumes the presented refresh token and returns a
  /// successor, so the new pair must be stored before anything else uses it.
  /// @param session Current session.
  /// @return The stored session with the new tokens.
  Future<AuthSession> refresh(AuthSession session) async {
    final Map<String, dynamic> json = await api.post(
      '/api/auth/refresh',
      body: <String, String>{'refreshToken': session.refreshToken},
      auth: false,
    );
    final AuthSession next = _sessionFrom(json, session.provider);
    return _persist(
      next.copyWith(onboardingRequired: session.onboardingRequired),
    );
  }

  /// @notice Asks the backend to mail a registration code.
  /// @dev A taken address is `EMAIL_TAKEN` so the form can return to the email
  /// step before the rest of the questions. The code itself arrives by email.
  /// @param email Address to verify.
  /// @return Future completing when the server has accepted the request.
  Future<void> requestEmailCode(String email) async {
    await api.post(
      '/api/auth/email-code',
      body: <String, String>{'email': email},
      auth: false,
    );
  }

  /// @notice Checks a registration code and leaves it usable for sign-up.
  /// @param email Address the code was sent to.
  /// @param code Four digits from the inbox.
  /// @return Future completing when the code is accepted.
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    await api.post(
      '/api/auth/email-code/verify',
      body: <String, String>{'email': email, 'code': code},
      auth: false,
    );
  }

  /// @notice Asks the backend to send a reset code.
  /// @dev Always succeeds for a well-formed email (no account enumeration).
  /// The code arrives by email. Outside production the server may also echo
  /// `devCode` for the suite; the phone does not show it.
  /// @param email Account email.
  /// @return The development code, or null when the server omits it.
  Future<String?> requestPasswordReset(String email) async {
    final Map<String, dynamic> json = await api.post(
      '/api/auth/forgot-password',
      body: <String, String>{'email': email},
      auth: false,
    );
    final String code = json.str('devCode');
    return code.isEmpty ? null : code;
  }

  /// @notice Checks a reset code and leaves it usable for the new password.
  /// @param email Account email.
  /// @param code Four digits from the inbox.
  /// @return Future completing when the code is accepted.
  Future<void> checkResetCode({
    required String email,
    required String code,
  }) async {
    await api.post(
      '/api/auth/reset-code/check',
      body: <String, String>{'email': email, 'code': code},
      auth: false,
    );
  }

  /// @notice Sets a new password with the emailed code.
  /// @param email Account email.
  /// @param code Four-digit reset code.
  /// @param newPassword At least 6 characters.
  /// @return Future completing when the password is changed.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await api.post(
      '/api/auth/reset-password',
      body: <String, String>{
        'email': email,
        'code': code,
        'newPassword': newPassword,
      },
      auth: false,
    );
  }

  /// @notice Stores the campus data collected after a Google sign-in.
  /// @param session Current session.
  /// @param name Display name.
  /// @param username Marketplace handle.
  /// @param universitas Campus name.
  /// @param programStudi Study programme.
  /// @return The profile row the server returned.
  Future<Map<String, dynamic>> completeOnboarding(
    AuthSession session, {
    required String name,
    required String username,
    required String universitas,
    required String programStudi,
  }) async {
    final Map<String, dynamic> json = await api.patch(
      '/api/users/me',
      body: <String, String>{
        'name': name,
        'username': username,
        'universitas': universitas,
        'programStudi': programStudi,
      },
    );
    return json.object('item') ?? const <String, dynamic>{};
  }

  /// @notice Clears the onboarding flag and refreshes the stored names.
  /// @param session Current session.
  /// @param name Display name now on the server.
  /// @param username Handle now on the server.
  /// @return The session with `onboardingRequired` set to false.
  Future<AuthSession> markOnboarded(
    AuthSession session, {
    String? name,
    String? username,
  }) {
    return _persist(
      session.copyWith(
        onboardingRequired: false,
        displayName: name,
        username: username,
      ),
    );
  }

  /// @notice Revokes the refresh token on the server, then forgets the session.
  /// @dev The remote call is best effort: signing out must work offline, and
  /// the local keys are what decides whether this device is signed in.
  /// @param session Session to end, or null to only clear the keystore.
  /// @return Future completing when the keystore is clean.
  Future<void> signOut([AuthSession? session]) async {
    if (session != null && session.refreshToken.isNotEmpty) {
      try {
        await api.post(
          '/api/auth/logout',
          body: <String, String>{'refreshToken': session.refreshToken},
          auth: false,
        );
      } on ApiException {
        // Already revoked, expired, or offline: the local sign-out still runs.
      }
    }
    await clear();
  }

  /// @notice Removes every session key from the keystore.
  /// @return Future completing when the keys are gone.
  Future<void> clear() async {
    await secure.delete(StorageKeys.accessToken);
    await secure.delete(StorageKeys.refreshToken);
    await secure.delete(StorageKeys.authEmail);
    await secure.delete(StorageKeys.authDisplayName);
    await secure.delete(StorageKeys.authProvider);
    await secure.delete(StorageKeys.authOnboarding);
    await secure.delete(StorageKeys.authUserId);
    await secure.delete(StorageKeys.authUsername);
    await secure.delete(StorageKeys.authRole);
    await secure.delete(StorageKeys.authNim);
  }

  /// @notice Keeps the student number from onboarding for verification.
  /// @param nim Digits typed on the student-number step.
  /// @return Future completing when the key is stored.
  Future<void> rememberNim(String nim) async {
    final String text = nim.trim();
    if (text.isEmpty) {
      return;
    }
    await secure.write(StorageKeys.authNim, text);
  }

  /// @notice Student number saved at onboarding, or empty.
  /// @return The stored NIM.
  Future<String> readNim() async {
    return (await secure.read(StorageKeys.authNim))?.trim() ?? '';
  }

  /// @notice Builds a session from an auth response.
  /// @param json `{user, token, refreshToken, onboardingRequired?}`.
  /// @param provider Provider that produced it.
  /// @return The session.
  AuthSession _sessionFrom(Map<String, dynamic> json, AuthProvider provider) {
    final Map<String, dynamic> user =
        json.object('user') ?? const <String, dynamic>{};
    final bool onboarding = json.containsKey('onboardingRequired')
        ? json.flag('onboardingRequired')
        : user.flag('onboardingRequired');
    return AuthSession(
      email: user.str('email'),
      displayName: user.str('name'),
      provider: provider,
      accessToken: json.str('token'),
      refreshToken: json.str('refreshToken'),
      onboardingRequired: onboarding,
      userId: user.str('id'),
      username: user.str('username'),
      role: user.str('role').isEmpty ? 'BUYER' : user.str('role'),
    );
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
    await secure.write(StorageKeys.authUserId, session.userId);
    await secure.write(StorageKeys.authUsername, session.username);
    await secure.write(StorageKeys.authRole, session.role);
    return session;
  }

  /// @notice Maps a stored provider name back to the enum.
  /// @param raw Stored value, null when unset.
  /// @return The matching provider, email by default.
  static AuthProvider _providerFrom(String? raw) {
    return raw == AuthProvider.google.name
        ? AuthProvider.google
        : AuthProvider.email;
  }
}
