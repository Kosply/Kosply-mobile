/// @title Session provider
/// @notice Global login state: null when signed out, otherwise the session.
/// @dev The tokens live in {SecureStore}; this notifier is the single source
/// watched by every screen, so sign-in and sign-out update the whole app at
/// once. {main} restores the stored session and seeds the initial value.
/// It also renews the access token for {ApiClient}: concurrent 401s share one
/// refresh, because the server rotates the refresh token and a second use of
/// the old one would revoke the whole session as a replay.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/google_id_token.dart';
import '../../core/database/providers/database_provider.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/json_read.dart';
import '../../core/storage/providers/storage_providers.dart';
import '../../data/account/session_repository.dart';
import '../../models/auth/auth_session.dart';
import '../network/api_provider.dart';
import 'profile_provider.dart';

/// @dev Session persistence and the `/api/auth/*` calls.
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(
    secure: ref.watch(secureStoreProvider),
    api: ref.watch(apiClientProvider),
  ),
);

/// @dev Google account picker. Overridden with a fake in widget tests.
final googleIdTokenSourceProvider = Provider<GoogleIdTokenSource>(
  (ref) => DeviceGoogleIdTokenSource(),
);

/// @title SessionNotifier
/// @notice Holds the active session and forwards writes to the repository.
class SessionNotifier extends Notifier<AuthSession?> {
  /// @notice Creates the notifier.
  /// @param initial Session restored at startup, null when signed out.
  /// @return A new {SessionNotifier} instance.
  SessionNotifier({this.initial});

  /// @dev Session restored at startup.
  final AuthSession? initial;

  /// @dev The refresh in flight, shared by every caller that hit a 401.
  Future<bool>? _refreshing;

  /// @notice Starts from the restored session.
  /// @return The initial session, or null.
  @override
  AuthSession? build() => initial;

  SessionRepository get _repo => ref.read(sessionRepositoryProvider);

  /// @notice Signs in with email and password.
  /// @param email Account email.
  /// @param password Account password.
  /// @return The new session.
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final AuthSession session = await _repo.signInWithEmail(
      email: email,
      password: password,
    );
    _publish(session);
    return session;
  }

  /// @notice Creates a buyer account and signs it in.
  /// @param email Account email.
  /// @param username Marketplace handle.
  /// @param name Display name.
  /// @param password Account password.
  /// @param universitas Campus name.
  /// @param programStudi Study programme.
  /// @param code Mailbox proof collected on the verification step.
  /// @return The new session.
  Future<AuthSession> register({
    required String email,
    required String username,
    required String name,
    required String password,
    required String universitas,
    required String programStudi,
    String? code,
  }) async {
    final AuthSession session = await _repo.register(
      email: email,
      username: username,
      name: name,
      password: password,
      universitas: universitas,
      programStudi: programStudi,
      code: code,
    );
    _publish(session);
    return session;
  }

  /// @notice Signs in with Google and publishes the new session.
  /// @return The new session; `onboardingRequired` for a new account.
  Future<AuthSession> signInWithGoogle() async {
    final String idToken = await ref
        .read(googleIdTokenSourceProvider)
        .idToken();
    final AuthSession session = await _repo.signInWithGoogle(idToken);
    _publish(session);
    return session;
  }

  /// @notice Saves the campus data collected during Google onboarding.
  /// @dev `PATCH /api/users/me`, then the cache and the onboarding flag.
  /// @param name Display name.
  /// @param username Handle shown on the marketplace.
  /// @param universitas Campus name.
  /// @param programStudi Study programme.
  /// @return Future completing when the server and the cache agree.
  Future<void> completeRegistration({
    required String name,
    required String username,
    required String universitas,
    required String programStudi,
  }) async {
    final AuthSession? session = state;
    if (session == null) {
      throw const ApiException(statusCode: 401, code: 'UNAUTHORIZED');
    }
    final Map<String, dynamic> user = await _repo.completeOnboarding(
      session,
      name: name,
      username: username,
      universitas: universitas,
      programStudi: programStudi,
    );
    await ref.read(accountRepositoryProvider).storeMe(user);
    state = await _repo.markOnboarded(
      session,
      name: user.str('name'),
      username: user.str('username'),
    );
  }

  /// @notice Asks the server to mail a registration code.
  /// @param email Address to verify.
  /// @return Future completing when the server has accepted the request.
  Future<void> requestEmailCode(String email) {
    return _repo.requestEmailCode(email);
  }

  /// @notice Checks a registration code without spending it.
  /// @param email Address the code was sent to.
  /// @param code Four digits from the inbox.
  /// @return Future completing when the code is accepted.
  Future<void> verifyEmailCode({
    required String email,
    required String code,
  }) {
    return _repo.verifyEmailCode(email: email, code: code);
  }

  /// @notice Asks the server for a password reset code.
  /// @param email Account email.
  /// @return The development code outside production, else null.
  Future<String?> requestPasswordReset(String email) {
    return _repo.requestPasswordReset(email);
  }

  /// @notice Checks a reset code without spending it.
  /// @param email Account email.
  /// @param code Four digits from the inbox.
  /// @return Future completing when the code is accepted.
  Future<void> checkResetCode({
    required String email,
    required String code,
  }) {
    return _repo.checkResetCode(email: email, code: code);
  }

  /// @notice Resets the password, then signs in with the new one.
  /// @param email Account email.
  /// @param code Reset code.
  /// @param newPassword New password.
  /// @return The new session.
  Future<AuthSession> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _repo.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
    return signInWithEmail(email: email, password: newPassword);
  }

  /// @notice Renews the access token once for every concurrent caller.
  /// @dev A refused refresh ends the session; a network failure keeps it so
  /// an offline phone is not signed out.
  /// @return True when a fresh access token is available.
  Future<bool> refreshTokens() {
    return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _refresh() async {
    final AuthSession? session = state;
    if (session == null) {
      return false;
    }
    try {
      state = await _repo.refresh(session);
      return true;
    } on ApiException catch (error) {
      if (error.isNetwork) {
        return false;
      }
      await _repo.clear();
      state = null;
      return false;
    }
  }

  /// @notice Revokes the session on the server and forgets this account.
  /// @dev Also clears the account's cached chats, tickets, saves, AI history
  /// and profile, so the next student on this phone starts clean.
  /// @return Future completing when the keystore and cache are clean.
  Future<void> signOut() async {
    final AuthSession? session = state;
    await _repo.signOut(session);
    state = null;
    await ref.read(appDatabaseProvider).clearAccountData();
  }

  /// @notice Publishes a fresh session.
  /// @dev Does not refresh the cache. {appSyncProvider} watches this notifier,
  /// so reading it from here is a provider cycle. Callers sync afterwards.
  /// @param session The session just stored.
  /// @return void
  void _publish(AuthSession session) {
    state = session;
  }
}

/// @dev Active session of the app; null when signed out.
final sessionProvider = NotifierProvider<SessionNotifier, AuthSession?>(
  SessionNotifier.new,
);

/// @dev Backend id of the signed-in student, empty when signed out.
final currentUserIdProvider = Provider<String>(
  (ref) => ref.watch(sessionProvider)?.userId ?? '',
);
