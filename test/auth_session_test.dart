/// @title Auth session tests
/// @notice Verifies the token pair lives in the keystore and that the global
/// session provider saves the profile collected during onboarding.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/database/app_database.dart';
import 'package:kosply_mobile/core/database/providers/database_provider.dart';
import 'package:kosply_mobile/core/network/api_client.dart';
import 'package:kosply_mobile/core/storage/keys/storage_keys.dart';
import 'package:kosply_mobile/core/storage/providers/storage_providers.dart';
import 'package:kosply_mobile/core/storage/stores/secure_store.dart';
import 'package:kosply_mobile/data/account/session_repository.dart';
import 'package:kosply_mobile/models/auth/auth_session.dart';
import 'package:kosply_mobile/providers/account/session_provider.dart';

import 'helpers/fake_backend.dart';
import 'helpers/kosply_test_app.dart';

/// @title _FixedTokens
/// @notice Token source for a repository built outside Riverpod.
class _FixedTokens implements ApiTokens {
  @override
  String? accessToken = FakeKosplyBackend.accessToken;

  @override
  Future<bool> refresh() async => true;
}

/// @notice Repository pointed at a fresh in-memory backend.
/// @param store Keystore the test inspects.
/// @param backend Backend the repository calls.
/// @return The repository.
SessionRepository _repository(SecureStore store, FakeKosplyBackend backend) {
  return SessionRepository(
    secure: store,
    api: ApiClient(
      transport: backend.client,
      baseUrl: FakeKosplyBackend.origin,
      tokens: _FixedTokens(),
    ),
  );
}

/// @notice Session persistence checks.
/// @return void
void main() {
  test('google sign-in stores the token pair in the keystore', () async {
    final SecureStore store = SecureStore.memory();
    final FakeKosplyBackend backend = FakeKosplyBackend();
    final SessionRepository repository = _repository(store, backend);

    final AuthSession session = await repository.signInWithGoogle(
      'test-google-id-token',
    );

    expect(session.email, FakeKosplyBackend.googleEmail);
    expect(session.provider, AuthProvider.google);
    expect(session.onboardingRequired, isTrue);
    expect(session.userId, FakeKosplyBackend.meId);
    expect(
      await store.read(StorageKeys.accessToken),
      FakeKosplyBackend.accessToken,
    );
    expect(
      await store.read(StorageKeys.refreshToken),
      FakeKosplyBackend.refreshToken,
    );

    final AuthSession? restored = await repository.restore();
    expect(restored, isNotNull);
    expect(restored!.accessToken, session.accessToken);
    expect(restored.onboardingRequired, isTrue);
  });

  test('sign-out removes every auth key', () async {
    final SecureStore store = SecureStore.memory();
    final SessionRepository repository = _repository(
      store,
      FakeKosplyBackend(),
    );
    await repository.signInWithGoogle('test-google-id-token');

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

    expect(
      await _repository(store, FakeKosplyBackend()).restore(),
      isNull,
    );
  });

  test('email sign-in skips onboarding', () async {
    final SessionRepository repository = _repository(
      SecureStore.memory(),
      FakeKosplyBackend(),
    );

    final AuthSession session = await repository.signInWithEmail(
      email: 'fajar@kampus.ac.id',
      password: 'rahasia123',
    );

    expect(session.email, 'fajar@kampus.ac.id');
    expect(session.provider, AuthProvider.email);
    expect(session.onboardingRequired, isFalse);
    expect(session.accessToken, FakeKosplyBackend.accessToken);
  });

  test('completeRegistration saves the profile and clears the flag', () async {
    final ProviderContainer container = await seededContainer(signedIn: false);
    final SessionNotifier session = container.read(sessionProvider.notifier);
    await session.signInWithGoogle();

    await session.completeRegistration(
      name: 'Fajar Arrizki',
      username: 'fajar.arrizki',
      universitas: 'Universitas Indonesia 45',
      programStudi: 'S1 Teknik Informatika',
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
    final ProviderContainer container = await seededContainer(signedIn: false);
    await container.read(sessionProvider.notifier).signInWithEmail(
      email: 'fajar@kampus.ac.id',
      password: 'rahasia123',
    );

    await container.read(sessionProvider.notifier).signOut();

    expect(container.read(sessionProvider), isNull);
    expect(
      await container.read(secureStoreProvider).read(StorageKeys.accessToken),
      isNull,
    );
  });
}
