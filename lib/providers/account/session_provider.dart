/// @title Session provider
/// @notice Global login state: null when signed out, otherwise the session.
/// @dev The tokens live in {SecureStore}; this notifier is the single source
/// watched by every screen, so sign-in and sign-out update the whole app at
/// once. {main} restores the stored session and seeds the initial value.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/providers/storage_providers.dart';
import '../../data/account/session_repository.dart';
import '../../models/account/user_profile.dart';
import '../../models/auth/auth_session.dart';
import 'profile_provider.dart';

/// @dev Session persistence through the keystore-backed {SecureStore}.
final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(secure: ref.watch(secureStoreProvider)),
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

  /// @notice Starts from the restored session.
  /// @return The initial session, or null.
  @override
  AuthSession? build() => initial;

  /// @notice Signs in with Google and publishes the new session.
  /// @return Future completing when the session is stored.
  Future<void> signInWithGoogle() async {
    state = await ref.read(sessionRepositoryProvider).signInWithGoogle();
  }

  /// @notice Signs in with an email address and publishes the new session.
  /// @param email Account email.
  /// @return Future completing when the session is stored.
  Future<void> signInWithEmail({required String email}) async {
    state = await ref
        .read(sessionRepositoryProvider)
        .signInWithEmail(email: email);
  }

  /// @notice Saves the name and username collected during onboarding.
  /// @dev Writes the cached profile row so every profile listener updates,
  /// then clears the onboarding flag on the session.
  /// @param name Display name.
  /// @param username Handle shown on the marketplace.
  /// @return Future completing when both writes are durable.
  Future<void> completeRegistration({
    required String name,
    required String username,
  }) async {
    final UserProfile current = ref.read(profileProvider);
    await ref
        .read(accountRepositoryProvider)
        .saveProfile(current.copyWith(name: name, username: username));
    final AuthSession? session = state;
    if (session != null) {
      state = await ref.read(sessionRepositoryProvider).markOnboarded(session);
    }
  }

  /// @notice Clears the session and every stored token.
  /// @return Future completing when the keystore is clean.
  Future<void> signOut() async {
    await ref.read(sessionRepositoryProvider).signOut();
    state = null;
  }
}

/// @dev Active session of the app; null when signed out.
final sessionProvider = NotifierProvider<SessionNotifier, AuthSession?>(
  SessionNotifier.new,
);
