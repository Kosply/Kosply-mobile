/// @title Auth session tests
/// @notice Verifies the token pair lives in the keystore and that the global
/// session provider saves the profile collected during onboarding.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/storage/keys/storage_keys.dart';
import 'package:kosply_mobile/core/storage/providers/storage_providers.dart';
import 'package:kosply_mobile/core/storage/stores/secure_store.dart';
import 'package:kosply_mobile/data/account/session_repository.dart';
import 'package:kosply_mobile/core/database/app_database.dart';
import 'package:kosply_mobile/core/database/providers/database_provider.dart';
import 'package:kosply_mobile/models/auth/auth_session.dart';
import 'package:kosply_mobile/providers/account/session_provider.dart';

/// @notice Session persistence checks.
/// @return void
void main() {
  test('google sign-in stores the token pair in the keystore', () async {
    final SecureStore store = SecureStore.memory();
    final SessionRepository repository = SessionRepository(secure: store);

    final AuthSession session = await repository.signInWithGoogle();

    expect(session.email, SessionRepository.googleDemoEmail);
    expect(session.provider, AuthProvider.google);
    expect(session.onboardingRequired, isTrue);
    expect(await store.read(StorageKeys.accessToken), isNotEmpty);
    expect(await store.read(StorageKeys.refreshToken), isNotEmpty);

    final AuthSession? restored = await repository.restore();
    expect(restored, isNotNull);
    expect(restored!.accessToken, session.accessToken);
    expect(restored.onboardingRequired, isTrue);
  });

  test('sign-out removes every auth key', () async {
    final SecureStore store = SecureStore.memory();
    final SessionRepository repository = SessionRepository(secure: store);
    await repository.signInWithGoogle();

    await repository.signOut();

    expect(await store.read(StorageKeys.accessToken), isNull);
    expect(await store.read(StorageKeys.refreshToken), isNull);
    expect(await store.read(StorageKeys.authEmail), isNull);
    expect(await store.read(StorageKeys.authProvider), isNull);
    expect(await repository.restore(), isNull);
  });

  test('a half-written session never restores', () async {
    final SecureStore store = SecureStore.memory();
    await store.write(StorageKeys.accessToken, 'stale.token');

    expect(await SessionRepository(secure: store).restore(), isNull);
  });

  test('email sign-in skips onboarding', () async {
    final SessionRepository repository = SessionRepository(
      secure: SecureStore.memory(),
    );

    final AuthSession session = await repository.signInWithEmail(
      email: 'fajar@kampus.ac.id',
    );

    expect(session.provider, AuthProvider.email);
    expect(session.onboardingRequired, isFalse);
  });

  test('completeRegistration saves the profile and clears the flag', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final SessionNotifier session = container.read(sessionProvider.notifier);
    await session.signInWithGoogle();

    await session.completeRegistration(
      name: 'Fajar Arrizki',
      username: 'fajar.arrizki',
    );

    expect(container.read(sessionProvider)?.onboardingRequired, isFalse);
    final UserRow? row = await container
        .read(appDatabaseProvider)
        .accountDao
        .profileOnce();
    expect(row?.name, 'Fajar Arrizki');
    expect(row?.username, 'fajar.arrizki');
  });

  test('sign-out clears the global session', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(sessionProvider.notifier).signInWithEmail(
          email: 'fajar@kampus.ac.id',
        );

    await container.read(sessionProvider.notifier).signOut();

    expect(container.read(sessionProvider), isNull);
    expect(
      await container.read(secureStoreProvider).read(StorageKeys.accessToken),
      isNull,
    );
  });
}
