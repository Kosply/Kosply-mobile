/// @title Real API smoke test
/// @notice Runs the app's repositories against a live Kosply server.
/// @dev Off unless invoked with
/// `--dart-define=KOSPLY_REAL_API=http://127.0.0.1:3500`.
/// Widget tests stay on {FakeKosplyBackend}: `testWidgets` freezes real
/// sockets, and those tests assert the fake seed rather than this database.
/// @author Kosply-mobile
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kosply_mobile/core/database/app_database.dart';
import 'package:kosply_mobile/core/network/api_client.dart';
import 'package:kosply_mobile/core/network/api_exception.dart';
import 'package:kosply_mobile/core/storage/stores/secure_store.dart';
import 'package:kosply_mobile/data/account/account_repository.dart';
import 'package:kosply_mobile/data/account/session_repository.dart';
import 'package:kosply_mobile/data/catalog/catalog_repository.dart';
import 'package:kosply_mobile/data/chat/ai_chat_repository.dart';
import 'package:kosply_mobile/data/inbox/inbox_repository.dart';
import 'package:kosply_mobile/data/support/support_repository.dart';
import 'package:kosply_mobile/models/account/user_profile.dart';
import 'package:kosply_mobile/models/auth/auth_session.dart';
import 'package:kosply_mobile/models/catalog/product.dart';
import 'package:kosply_mobile/models/support/help_topic.dart';

/// @dev Live origin. Empty skips the test so `flutter test` stays offline.
const String _realApi = String.fromEnvironment('KOSPLY_REAL_API');

/// @title _LiveTokens
/// @notice Bearer token the smoke test sets after register.
class _LiveTokens implements ApiTokens {
  /// @dev Access token from the session just stored.
  String? token;

  @override
  String? get accessToken => token;

  @override
  Future<bool> refresh() async => false;
}

/// @notice Live-server checks for the mobile client.
/// @return void
void main() {
  test('repositories register and sync against the live server', () async {
    if (_realApi.isEmpty) {
      markTestSkipped(
        'Pass --dart-define=KOSPLY_REAL_API=http://127.0.0.1:3500',
      );
      return;
    }

    final http.Client transport = http.Client();
    addTearDown(transport.close);
    final SecureStore secure = SecureStore.memory();
    final _LiveTokens tokens = _LiveTokens();
    final ApiClient api = ApiClient(
      transport: transport,
      baseUrl: _realApi,
      tokens: tokens,
    );
    final int stamp = DateTime.now().millisecondsSinceEpoch;
    // Suite addresses register without a mailbox proof. A real inbox has to
    // present the code from POST /api/auth/email-code.
    final String email = 'real-api-$stamp@kosply.test';
    final String username = 'r${stamp % 100000000}';

    final AuthSession session = await SessionRepository(
      secure: secure,
      api: api,
    ).register(
      email: email,
      username: username,
      name: 'Real API',
      password: 'password',
      universitas: 'Kosply',
      programStudi: 'Teknik',
    );
    tokens.token = session.accessToken;

    expect(session.email, email);
    expect(session.userId, isNotEmpty);
    expect(session.accessToken, isNotEmpty);
    expect(session.refreshToken, isNotEmpty);

    final AppDatabase db = AppDatabase.memory();
    addTearDown(db.close);
    final CatalogRepository catalog = CatalogRepository(
      dao: db.catalogDao,
      api: api,
    );
    final AccountRepository account = AccountRepository(
      dao: db.accountDao,
      api: api,
    );
    final InboxRepository inbox = InboxRepository(
      dao: db.inboxDao,
      api: api,
      currentUserId: session.userId,
    );
    final SupportRepository support = SupportRepository(
      dao: db.supportDao,
      api: api,
    );
    final AiChatRepository aiChat = AiChatRepository(
      dao: db.aiChatDao,
      api: api,
      currentUserId: session.userId,
    );

    await _step('GET /api/products', catalog.refresh);
    await _step('GET /api/support/help-topics', support.refreshHelpTopics);
    await _step('GET /api/users/me', account.refreshMe);
    await _step('GET /api/favorites', catalog.refreshFavorites);
    await _step('GET /api/conversations', inbox.refresh);
    await _step('GET /api/support/tickets', support.refreshTickets);
    await _step('GET /api/ai/conversations', aiChat.refreshThreads);

    final List<Product> products = await catalog.watchProducts().first;
    final List<HelpTopic> topics = await support.watchHelpTopics().first;
    final UserProfile profile = await account.watchProfile().first;

    expect(products, isNotEmpty, reason: 'live catalogue is empty');
    expect(topics, isNotEmpty, reason: 'live FAQ is empty');
    expect(profile.name, 'Real API');
    expect(profile.username, username);
    // ignore: avoid_print
    print(
      'live ok: ${products.length} products, first "${products.first.title}"; '
      '${topics.length} help topics; signed in as $email',
    );
  });
}

/// @notice Runs one live call and names the route when it fails.
/// @param label Route under test.
/// @param call Repository refresh.
/// @return Future completing when the call settles.
Future<void> _step(String label, Future<void> Function() call) async {
  try {
    await call();
  } on ApiException catch (error) {
    fail('$label -> ${error.statusCode} ${error.code} ${error.message}');
  }
}
