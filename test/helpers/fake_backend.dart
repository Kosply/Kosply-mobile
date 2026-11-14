/// @title Fake Kosply backend
/// @notice In-memory stand-in for the Express API, served through
/// `package:http`'s [MockClient].
/// @dev Answers with the same envelopes and shapes as `lib/server` (see
/// `postman/specs/tables/*.md` in Kosply-backend), seeded from the fixture
/// data the widget tests already assert on. Repositories therefore run their
/// real HTTP, mapping and cache code in every widget test. The signed-in
/// student is [meId]; every request is recorded in [requests].
/// @author Kosply-mobile
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kosply_mobile/core/database/app_database.dart';

import 'fixtures/local_user.dart';
import 'fixtures/placeholder_ai_chat.dart';
import 'fixtures/placeholder_catalog.dart';
import 'fixtures/placeholder_help.dart';
import 'fixtures/placeholder_inbox.dart';

/// @title FakeKosplyBackend
/// @notice Routes, state, and knobs for widget tests.
class FakeKosplyBackend {
  /// @notice Creates the backend seeded with the fixture data.
  /// @return A new {FakeKosplyBackend} instance.
  FakeKosplyBackend() {
    _seed();
  }

  /// @dev Origin the test client is pointed at.
  static const String origin = 'http://kosply.test';

  /// @dev Backend id of the signed-in student.
  static const String meId = localUserId;

  /// @dev Access token the seeded session carries.
  static const String accessToken = 'test-access-token';

  /// @dev Refresh token the seeded session carries.
  static const String refreshToken = 'test-refresh-token';

  /// @dev Email whose registration answers `409 EMAIL_TAKEN`.
  static const String takenEmail = 'taken@kampus.ac.id';

  /// @dev Password the login route refuses with `INVALID_CREDENTIALS`.
  static const String wrongPassword = 'wrong-password';

  /// @dev Reset code `/auth/reset-password` accepts.
  static const String resetCode = '1234';

  /// @dev Email the Google route signs in.
  static const String googleEmail = 'fajar.arrizki@gmail.com';

  /// @dev Name the Google route signs in.
  static const String googleName = 'Fajar Arrizki';

  /// @dev Every request received, in order.
  final List<http.Request> requests = <http.Request>[];

  /// @dev Registration codes issued by `/auth/email-code`, keyed by email.
  final Map<String, String> emailCodes = <String, String>{};

  /// @dev When true every call fails like an unreachable server.
  bool offline = false;

  /// @dev Users by id, public columns plus email.
  final Map<String, Map<String, dynamic>> users =
      <String, Map<String, dynamic>>{};

  /// @dev Products by id, with `sellerId`, newest first in [productOrder].
  final Map<String, Map<String, dynamic>> products =
      <String, Map<String, dynamic>>{};

  /// @dev Product ids, newest first.
  final List<String> productOrder = <String>[];

  /// @dev Saved product ids, newest save first.
  final List<String> favorites = <String>[];

  /// @dev COD rooms by id.
  final Map<String, Map<String, dynamic>> rooms =
      <String, Map<String, dynamic>>{};

  /// @dev Bubbles per room, oldest first.
  final Map<String, List<Map<String, dynamic>>> messages =
      <String, List<Map<String, dynamic>>>{};

  /// @dev FAQ topics in display order.
  final List<Map<String, dynamic>> helpTopics = <Map<String, dynamic>>[];

  /// @dev Tickets by id.
  final Map<String, Map<String, dynamic>> tickets =
      <String, Map<String, dynamic>>{};

  /// @dev Ticket bubbles per ticket, oldest first.
  final Map<String, List<Map<String, dynamic>>> ticketMessages =
      <String, List<Map<String, dynamic>>>{};

  /// @dev AI sessions by id.
  final Map<String, Map<String, dynamic>> aiSessions =
      <String, Map<String, dynamic>>{};

  /// @dev AI transcripts per session.
  final Map<String, List<Map<String, dynamic>>> aiHistory =
      <String, List<Map<String, dynamic>>>{};

  /// @dev Notification preferences the app pushed.
  final Map<String, bool> notificationPrefs = <String, bool>{};

  /// @dev The card a photo turn of `/api/ai/chat` returns.
  Map<String, dynamic> listingCard = <String, dynamic>{
    'title': 'Kipas angin meja 3 kecepatan',
    'description': 'Kipas meja putih, tiga kecepatan, baling-baling utuh.',
    'category': 'Elektronik',
  };

  /// @dev When set, `/api/ai/chat` fails with this code.
  String? aiErrorCode;

  /// @dev Callbacks a chatbot turn returns for the phone to run.
  List<Map<String, dynamic>> aiCallbacks = <Map<String, dynamic>>[];

  /// @dev Reasoning text the AI stream emits before the answer.
  String aiThinking = '';

  /// @dev When true the stream pauses for Setujui / Tolak instead of finishing.
  bool aiNeedsApproval = false;

  /// @dev Status returned by `GET /api/ai/wait/:id`. `noop` finishes at once.
  String aiWaitStatus = 'noop';

  /// @dev Catalogue events the app posted.
  final List<Map<String, String>> analyticsEvents = <Map<String, String>>[];

  /// @dev Personal notifications, newest first after a list call.
  final List<Map<String, dynamic>> notifications = <Map<String, dynamic>>[];

  /// @dev The caller's KTM application, null until they submit.
  Map<String, dynamic>? verification;

  /// @dev Reports the buyer filed.
  final List<Map<String, dynamic>> reports = <Map<String, dynamic>>[];

  /// @dev When set, `POST /api/products` fails with this code.
  String? createProductErrorCode;

  int _seq = 0;
  int _aiReplies = 0;
  int _uploads = 0;

  /// @notice HTTP client that routes into this backend.
  /// @return The mock client.
  http.Client get client => MockClient(_handle);

  /// @notice Requests matching [method] and [path] (path without query).
  /// @param method HTTP verb.
  /// @param path Request path.
  /// @return The matching requests.
  List<http.Request> calls(String method, String path) {
    return <http.Request>[
      for (final http.Request request in requests)
        if (request.method == method && request.url.path == path) request,
    ];
  }

  /// @notice Decoded JSON body of [request].
  /// @param request A recorded request.
  /// @return The body object.
  static Map<String, dynamic> bodyOf(http.BaseRequest request) {
    final String text = (request as http.Request).body;
    return text.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(text) as Map<String, dynamic>;
  }

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    if (offline) {
      throw http.ClientException('offline', request.url);
    }
    final String method = request.method;
    final List<String> parts = request.url.pathSegments;
    if (parts.length < 2 || parts.first != 'api') {
      return _error(404, 'ROUTE_NOT_FOUND');
    }
    final List<String> p = parts.sublist(1);
    final Map<String, String> q = request.url.queryParameters;
    final Map<String, dynamic> body = method == 'GET' || method == 'DELETE'
        ? <String, dynamic>{}
        : (request.headers['content-type']?.startsWith('application/json') ??
              false)
        ? bodyOf(request)
        : <String, dynamic>{};
    final bool authed =
        request.headers['authorization'] == 'Bearer $accessToken';

    switch (p) {
      case ['auth', 'login']:
        return _login(body);
      case ['auth', 'register']:
        return _register(body);
      case ['auth', 'google']:
        return _google(body);
      case ['auth', 'refresh']:
        return body['refreshToken'] == refreshToken
            ? _ok(_session(users[meId]!))
            : _error(401, 'TOKEN_REVOKED');
      case ['auth', 'logout']:
        return _ok(<String, dynamic>{'revoked': 1});
      case ['auth', 'forgot-password']:
        return _ok(<String, dynamic>{'devCode': resetCode});
      case ['auth', 'reset-code', 'check']:
        return body['code'] == resetCode
            ? _ok(<String, dynamic>{})
            : _error(400, 'RESET_INVALID');
      case ['auth', 'reset-password']:
        return body['code'] == resetCode
            ? _ok(<String, dynamic>{})
            : _error(400, 'RESET_INVALID');
      case ['auth', 'email-code']:
        if (body['email'] == takenEmail) {
          return _error(409, 'EMAIL_TAKEN');
        }
        emailCodes['${body['email']}'] = resetCode;
        return _ok(<String, dynamic>{'devCode': resetCode});
      case ['auth', 'email-code', 'verify']:
        return emailCodes['${body['email']}'] == body['code']
            ? _ok(<String, dynamic>{})
            : _error(400, 'EMAIL_CODE_INVALID');
      case ['products'] when method == 'GET':
        return _ok(<String, dynamic>{'items': _listProducts(q)});
      case ['products'] when method == 'POST':
        if (!authed) {
          return _error(401, 'UNAUTHORIZED');
        }
        return _createProduct(body);
      case ['products', final String id] when method == 'GET':
        final Map<String, dynamic>? product = products[id];
        return product == null
            ? _error(404, 'PRODUCT_NOT_FOUND')
            : _ok(<String, dynamic>{
                'item': _productJson(product, detail: true),
              });
      case ['users', 'me'] when method == 'GET':
        return authed
            ? _ok(<String, dynamic>{'item': _profile(meId)})
            : _error(401, 'UNAUTHORIZED');
      case ['users', 'me'] when method == 'PATCH':
        return _updateMe(body);
      case ['users', final String id]:
        return users.containsKey(id)
            ? _ok(<String, dynamic>{'item': _profile(id)})
            : _error(404, 'USER_NOT_FOUND');
      case ['favorites'] when method == 'GET':
        return _ok(<String, dynamic>{
          'items': <Map<String, dynamic>>[
            for (final String id in favorites)
              if (products[id] != null) _productJson(products[id]!),
          ],
        });
      case ['favorites', final String id] when method == 'PUT':
        if (!products.containsKey(id)) {
          return _error(404, 'PRODUCT_NOT_FOUND');
        }
        favorites
          ..remove(id)
          ..insert(0, id);
        return _ok(<String, dynamic>{
          'item': <String, dynamic>{'productId': id},
        }, status: 201);
      case ['favorites', final String id] when method == 'DELETE':
        final bool removed = favorites.remove(id);
        return _ok(<String, dynamic>{
          'item': <String, dynamic>{'productId': id, 'removed': removed},
        });
      case ['conversations'] when method == 'GET':
        return _ok(<String, dynamic>{'items': _inbox()});
      case ['conversations'] when method == 'POST':
        return _openRoom(body);
      case ['conversations', final String id] when method == 'GET':
        return rooms.containsKey(id)
            ? _ok(<String, dynamic>{'item': _room(id, withMessages: true)})
            : _error(404, 'CONVERSATION_NOT_FOUND');
      case ['conversations', final String id, 'messages'] when method == 'GET':
        if (!rooms.containsKey(id)) {
          return _error(404, 'CONVERSATION_NOT_FOUND');
        }
        for (final Map<String, dynamic> m in messages[id] ?? const []) {
          if (m['senderId'] != meId) {
            m['isRead'] = true;
          }
        }
        return _ok(<String, dynamic>{'items': messages[id] ?? const []});
      case ['conversations', final String id, 'messages'] when method == 'POST':
        return _send(id, body);
      case ['support', 'help-topics']:
        return _ok(<String, dynamic>{'items': helpTopics});
      case ['support', 'tickets'] when method == 'GET':
        return _ok(<String, dynamic>{'items': tickets.values.toList()});
      case ['support', 'tickets'] when method == 'POST':
        return _openTicket(body);
      case ['support', 'tickets', final String id] when method == 'GET':
        final Map<String, dynamic>? ticket = tickets[id];
        return ticket == null
            ? _error(404, 'TICKET_NOT_FOUND')
            : _ok(<String, dynamic>{
                'item': <String, dynamic>{
                  ...ticket,
                  'messages': ticketMessages[id] ?? const [],
                },
              });
      case ['support', 'tickets', final String id, 'messages']:
        return _replyTicket(id, body);
      case ['ai', 'conversations']:
        return _ok(<String, dynamic>{'items': aiSessions.values.toList()});
      case ['ai', 'history', final String id]:
        return _ok(<String, dynamic>{
          'conversation_id': id,
          'messages': aiHistory[id] ?? const [],
        });
      case ['ai', 'chat']:
        return _aiTurn(body);
      case ['uploads', 'images']:
        _uploads += 1;
        return _ok(<String, dynamic>{
          'item': <String, dynamic>{
            'url': '$origin/uploads/photo$_uploads.jpg',
            'contentType': request.headers['content-type'],
            'size': request.bodyBytes.length,
          },
        }, status: 201);
      case ['products', final String id, 'sold'] when method == 'PATCH':
        return _sold(id);
      case ['products', final String id] when method == 'PATCH':
        return _updateProduct(id, body);
      case ['products', final String id] when method == 'DELETE':
        return _archive(id);
      case ['analytics', 'seller']:
        return _ok(<String, dynamic>{'item': _analytics()});
      case ['analytics', 'products', final String id, 'event']
          when method == 'POST':
        return _event(id, q);
      case ['analytics', 'products', final String id] when method == 'GET':
        return _productStats(id);
      case ['notifications'] when method == 'GET':
        return _notificationList();
      case ['notifications', 'read-all'] when method == 'POST':
        return _markAll();
      case ['notifications', final String id, 'read'] when method == 'POST':
        return _markOne(id);
      case ['notifications', 'preferences'] when method == 'GET':
        return _prefs();
      case ['notifications', 'preferences'] when method == 'PATCH':
        notificationPrefs[body['key'] as String] = body['enabled'] as bool;
        return _ok(<String, dynamic>{'item': body});
      case ['verifications'] when method == 'POST':
        return _submitVerification(body);
      case ['verifications', 'me'] when method == 'GET':
        return _myVerification();
      case ['reports'] when method == 'POST':
        return _report(body);
      case ['support', 'tickets', final String id, 'close'] when method == 'POST':
        return _closeTicket(id);
      case ['conversations', final String id, 'stream'] when method == 'GET':
        return _chatStream(id);
      case ['conversations', final String id, 'wait'] when method == 'GET':
        return _chatWait(id);
      case ['ai', 'chat', 'stream'] when method == 'POST':
        return _aiStream(body);
      case ['ai', 'chat', 'resume'] when method == 'POST':
        return _aiResume(body);
      case ['ai', 'wait', final String id] when method == 'GET':
        return _aiWait(id);
    }
    return _error(404, 'ROUTE_NOT_FOUND');
  }

  // ---------------------------------------------------------------- seed ---

  void _seed() {
    final int now = DateTime.now().toUtc().millisecondsSinceEpoch;
    users[meId] = <String, dynamic>{
      'id': meId,
      'email': 'me@kampus.ac.id',
      'username': 'kamu',
      'name': 'Kamu',
      'role': 'SELLER',
      'universitas': 'Universitas Indonesia',
      'programStudi': 'S1 Teknik Informatika',
      'bio': 'Lagi beres-beres kos, semua barang masih layak pakai.',
      'photo': null,
    };
    for (final UsersCompanion row in PlaceholderCatalog.userRows(now: now)) {
      users[row.id.value] = <String, dynamic>{
        'id': row.id.value,
        'email': '${row.id.value}@kampus.ac.id',
        'username': row.username.value,
        'name': row.name.value,
        'role': row.role.value,
        'universitas': 'Universitas Indonesia',
        'programStudi': 'S1 Teknik Informatika',
        'bio': row.bio.value,
        'photo': row.photo.value,
      };
    }
    for (final ProductsCompanion row in PlaceholderCatalog.productRows(
      now: now,
    )) {
      _putProduct(<String, dynamic>{
        'id': row.id.value,
        'sellerId': row.sellerId.value,
        'title': row.title.value,
        'description': row.description.value,
        'price': row.price.value,
        'stock': row.stock.value,
        'imageUrls': jsonDecode(row.imageUrls.value),
        'category': row.category.value,
        'latitude': null,
        'longitude': null,
        'locationLabel': row.locationLabel.value,
        'status': 'ACTIVE',
        'createdAt': _iso(row.createdAt.value),
        'updatedAt': _iso(row.backendUpdatedAt.value),
      });
    }
    for (final ConversationsCompanion row in PlaceholderInbox.conversationRows(
      now: now,
    )) {
      rooms[row.id.value] = <String, dynamic>{
        'id': row.id.value,
        'productId': row.productId.value,
        'buyerId': row.buyerId.value,
        'sellerId': row.sellerId.value,
        'lastMessageAt': _iso(row.lastMessageAt.value),
        'createdAt': _iso(row.createdAt.value),
        'updatedAt': _iso(row.backendUpdatedAt.value),
      };
    }
    for (final MessagesCompanion row in PlaceholderInbox.messageRows(
      now: now,
    )) {
      (messages[row.conversationId.value] ??= <Map<String, dynamic>>[]).add(
        <String, dynamic>{
          'id': row.id.value,
          'conversationId': row.conversationId.value,
          'senderId': row.senderId.value,
          'type': 'TEXT',
          'text': row.body.value,
          'imageUrl': null,
          'isRead': row.isRead.value,
          'createdAt': _iso(row.createdAt.value),
        },
      );
    }
    for (final HelpTopicsCompanion row in PlaceholderHelp.topicRows(now: now)) {
      helpTopics.add(<String, dynamic>{
        'id': row.id.value,
        'title': row.title.value,
        'answer': row.answer.value,
        'sortOrder': row.sortOrder.value,
      });
    }
    for (final SupportTicketsCompanion row in PlaceholderHelp.ticketRows(
      now: now,
    )) {
      tickets[row.id.value] = <String, dynamic>{
        'id': row.id.value,
        'ticketNo': 'KSP-${row.id.value}',
        'userId': meId,
        'category': row.category.value,
        'status': row.status.value,
        'subject': row.subject.value,
        'description': row.description.value,
        'lastMessageAt': _iso(row.lastMessageAt.value),
        'createdAt': _iso(row.createdAt.value),
      };
    }
    for (final SupportMessagesCompanion row
        in PlaceholderHelp.ticketMessageRows(now: now)) {
      (ticketMessages[row.ticketId.value] ??= <Map<String, dynamic>>[]).add(
        <String, dynamic>{
          'id': row.id.value,
          'ticketId': row.ticketId.value,
          'senderId': row.senderId.value,
          'senderRole': row.senderRole.value,
          'senderName': row.senderName.present ? row.senderName.value : '',
          'text': row.body.value,
          'isInternal': false,
          'isRead': row.isRead.value,
          'createdAt': _iso(row.createdAt.value),
        },
      );
    }
    final List<AiConversationsCompanion> sessions =
        PlaceholderAiChat.conversationRows(now: now);
    for (final AiConversationsCompanion row in sessions) {
      aiSessions[row.id.value] = <String, dynamic>{
        'id': row.id.value,
        'userId': meId,
        'title': row.title.value,
        'lastMessageAt': _iso(row.lastMessageAt.value),
        'createdAt': _iso(row.createdAt.value),
      };
    }
    for (final AiMessagesCompanion row in PlaceholderAiChat.messageRows(
      now: now,
    )) {
      (aiHistory[row.conversationId.value] ??= <Map<String, dynamic>>[]).add(
        <String, dynamic>{
          'role': row.role.value == 'USER' ? 'human' : 'ai',
          'content': row.content.value,
        },
      );
    }
    notifications.add(<String, dynamic>{
      'id': 'note-1',
      'type': 'chat',
      'title': 'Pesan baru',
      'body': 'Ada chat baru.',
      'isRead': false,
      'readAt': null,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'data': <String, dynamic>{},
    });
  }

  void _putProduct(Map<String, dynamic> product) {
    products[product['id'] as String] = product;
    productOrder
      ..remove(product['id'])
      ..add(product['id'] as String);
  }

  // -------------------------------------------------------------- shapes ---

  Map<String, dynamic> _publicSeller(String id) {
    final Map<String, dynamic> user = users[id] ?? <String, dynamic>{'id': id};
    return <String, dynamic>{
      'id': id,
      'username': user['username'],
      'name': user['name'],
      'role': user['role'],
      'universitas': user['universitas'],
      'photo': user['photo'],
    };
  }

  Map<String, dynamic> _profile(String id) {
    final Map<String, dynamic> user = users[id]!;
    return <String, dynamic>{
      for (final String key in <String>[
        'id',
        'username',
        'name',
        'role',
        'universitas',
        'programStudi',
        'bio',
        'photo',
      ])
        key: user[key],
    };
  }

  Map<String, dynamic> _productJson(
    Map<String, dynamic> product, {
    bool detail = false,
  }) {
    return <String, dynamic>{
      for (final String key in <String>[
        'id',
        'title',
        'price',
        'stock',
        'imageUrls',
        'category',
        'latitude',
        'longitude',
        'locationLabel',
        'createdAt',
        'updatedAt',
      ])
        key: product[key],
      if (detail) 'description': product['description'],
      if (detail) 'status': product['status'],
      'seller': _publicSeller(product['sellerId'] as String),
    };
  }

  List<Map<String, dynamic>> _listProducts(Map<String, String> q) {
    final String needle = (q['q'] ?? '').toLowerCase();
    final String? sellerId = q['sellerId'];
    final int limit = int.tryParse(q['limit'] ?? '') ?? 20;
    final List<Map<String, dynamic>> listed = <Map<String, dynamic>>[
      for (final String id in productOrder)
        if (products[id]!['status'] == 'ACTIVE' &&
            (sellerId == null || products[id]!['sellerId'] == sellerId) &&
            (needle.isEmpty ||
                (products[id]!['title'] as String).toLowerCase().contains(
                  needle,
                )))
          _productJson(products[id]!),
    ];
    // The product service orders `createdAt` descending.
    listed.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      final String left = a['createdAt'] as String? ?? '';
      final String right = b['createdAt'] as String? ?? '';
      return right.compareTo(left);
    });
    return listed.take(limit).toList();
  }

  Map<String, dynamic> _room(String id, {bool withMessages = false}) {
    final Map<String, dynamic> room = rooms[id]!;
    final List<Map<String, dynamic>> thread =
        messages[id] ?? const <Map<String, dynamic>>[];
    final Map<String, dynamic>? product = products[room['productId']];
    return <String, dynamic>{
      ...room,
      'product': product == null
          ? null
          : <String, dynamic>{
              'id': product['id'],
              'title': product['title'],
              'price': product['price'],
            },
      'buyer': _publicSeller(room['buyerId'] as String),
      'seller': _publicSeller(room['sellerId'] as String),
      if (withMessages) 'messages': thread,
    };
  }

  List<Map<String, dynamic>> _inbox() {
    return <Map<String, dynamic>>[
      for (final String id in rooms.keys)
        if (rooms[id]!['buyerId'] == meId || rooms[id]!['sellerId'] == meId)
          <String, dynamic>{
            ..._room(id),
            'lastMessage':
                (messages[id] ?? const <Map<String, dynamic>>[]).lastOrNull,
            'unreadCount': (messages[id] ?? const <Map<String, dynamic>>[])
                .where(
                  (Map<String, dynamic> m) =>
                      m['senderId'] != meId && m['isRead'] != true,
                )
                .length,
            '_count': <String, int>{
              'messages': (messages[id] ?? const []).length,
            },
          },
    ];
  }

  Map<String, dynamic> _analytics() {
    final List<Map<String, dynamic>> mine = <Map<String, dynamic>>[
      for (final Map<String, dynamic> product in products.values)
        if (product['sellerId'] == meId) product,
    ];
    return <String, dynamic>{
      'range': <String, dynamic>{'days': 30},
      'totals': <String, int>{
        'products': mine.length,
        'impressions': 1284,
        'clicks': 120,
        'favorites': 46,
        'inquiries': 18,
        'sales': 7,
      },
      'items': <Map<String, dynamic>>[
        for (int i = 0; i < mine.length; i++)
          <String, dynamic>{
            'productId': mine[i]['id'],
            'impressions': 100 - i,
            'clicks': 10 - i,
          },
      ],
    };
  }

  // ------------------------------------------------------------- writes ---

  http.Response _login(Map<String, dynamic> body) {
    if (body['password'] == wrongPassword) {
      return _error(401, 'INVALID_CREDENTIALS');
    }
    users[meId]!['email'] = body['email'];
    return _ok(_session(users[meId]!));
  }

  http.Response _register(Map<String, dynamic> body) {
    if (body['email'] == takenEmail) {
      return _error(409, 'EMAIL_TAKEN');
    }
    final String? issued = emailCodes['${body['email']}'];
    if (issued != null && body['code'] != issued) {
      return _error(400, 'EMAIL_CODE_INVALID');
    }
    users[meId]!
      ..['email'] = body['email']
      ..['name'] = body['name']
      ..['username'] = body['username']
      ..['universitas'] = body['universitas']
      ..['programStudi'] = body['programStudi'];
    return _ok(_session(users[meId]!), status: 201);
  }

  http.Response _google(Map<String, dynamic> body) {
    users[meId]!
      ..['email'] = googleEmail
      ..['name'] = googleName;
    final Map<String, dynamic> session = _session(users[meId]!);
    final Map<String, dynamic> user = Map<String, dynamic>.of(
      session['user'] as Map<String, dynamic>,
    )..['onboardingRequired'] = true;
    return _ok(<String, dynamic>{
      ...session,
      'user': user,
      'onboardingRequired': true,
      'isNew': true,
    });
  }

  Map<String, dynamic> _session(Map<String, dynamic> user) {
    return <String, dynamic>{
      'user': <String, dynamic>{
        'id': user['id'],
        'email': user['email'],
        'username': user['username'],
        'name': user['name'],
        'role': user['role'],
        'universitas': user['universitas'],
        'programStudi': user['programStudi'],
        'onboardingRequired': false,
      },
      'token': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': '2099-01-01T00:00:00.000Z',
    };
  }

  http.Response _updateMe(Map<String, dynamic> body) {
    final Map<String, dynamic> me = users[meId]!;
    for (final String key in <String>[
      'name',
      'username',
      'bio',
      'photo',
      'universitas',
      'programStudi',
    ]) {
      if (body.containsKey(key)) {
        me[key] = body[key];
      }
    }
    return _ok(<String, dynamic>{'item': _profile(meId)});
  }

  http.Response _createProduct(Map<String, dynamic> body) {
    final String? code = createProductErrorCode;
    if (code != null) {
      return _error(code == 'SELLER_NOT_APPROVED' ? 403 : 400, code);
    }
    final String id = 'created-${_seq += 1}';
    _putProduct(<String, dynamic>{
      'id': id,
      'sellerId': meId,
      'title': body['title'],
      'description': body['description'],
      'price': body['price'],
      'stock': body['stock'] ?? 1,
      'imageUrls': body['imageUrls'] ?? <String>[],
      'category': body['category'],
      'latitude': null,
      'longitude': null,
      'locationLabel': body['locationLabel'],
      'status': 'ACTIVE',
    });
    return _ok(<String, dynamic>{
      'item': _productJson(products[id]!, detail: true),
    }, status: 201);
  }

  http.Response _openRoom(Map<String, dynamic> body) {
    final String? productId = body['productId'] as String?;
    final String? sellerId = productId == null
        ? body['sellerId'] as String?
        : products[productId]?['sellerId'] as String?;
    if (sellerId == null) {
      return _error(404, 'PRODUCT_NOT_FOUND');
    }
    if (sellerId == meId) {
      return _error(400, 'VALIDATION');
    }
    for (final String id in rooms.keys) {
      final Map<String, dynamic> room = rooms[id]!;
      if (room['buyerId'] == meId &&
          room['sellerId'] == sellerId &&
          (productId == null || room['productId'] == productId)) {
        return _ok(<String, dynamic>{
          'item': _room(id, withMessages: true),
        }, status: 201);
      }
    }
    final String id = 'room-${_seq += 1}';
    final String now = DateTime.now().toUtc().toIso8601String();
    rooms[id] = <String, dynamic>{
      'id': id,
      'productId': productId,
      'buyerId': meId,
      'sellerId': sellerId,
      'lastMessageAt': null,
      'createdAt': now,
      'updatedAt': now,
    };
    return _ok(<String, dynamic>{
      'item': _room(id, withMessages: true),
    }, status: 201);
  }

  http.Response _send(String roomId, Map<String, dynamic> body) {
    if (!rooms.containsKey(roomId)) {
      return _error(404, 'CONVERSATION_NOT_FOUND');
    }
    final String now = DateTime.now().toUtc().toIso8601String();
    final Map<String, dynamic> message = <String, dynamic>{
      'id': 'msg-${_seq += 1}',
      'conversationId': roomId,
      'senderId': meId,
      'type': body['type'] ?? 'TEXT',
      'text': body['text'],
      'isRead': false,
      'createdAt': now,
    };
    (messages[roomId] ??= <Map<String, dynamic>>[]).add(message);
    rooms[roomId]!['lastMessageAt'] = now;
    return _ok(<String, dynamic>{'item': message}, status: 201);
  }

  http.Response _openTicket(Map<String, dynamic> body) {
    final String id = 'ticket-new-${_seq += 1}';
    final String now = DateTime.now().toUtc().toIso8601String();
    tickets[id] = <String, dynamic>{
      'id': id,
      'ticketNo': 'KSP-$id',
      'userId': meId,
      'category': body['category'],
      'status': 'OPEN',
      'subject': body['subject'],
      'description': body['description'],
      'lastMessageAt': now,
      'createdAt': now,
    };
    return _ok(<String, dynamic>{'item': tickets[id]}, status: 201);
  }

  http.Response _replyTicket(String ticketId, Map<String, dynamic> body) {
    final Map<String, dynamic>? ticket = tickets[ticketId];
    if (ticket == null) {
      return _error(404, 'TICKET_NOT_FOUND');
    }
    if (ticket['status'] == 'CLOSED') {
      return _error(409, 'TICKET_CLOSED');
    }
    final Map<String, dynamic> message = <String, dynamic>{
      'id': 'tmsg-${_seq += 1}',
      'ticketId': ticketId,
      'senderId': meId,
      'senderRole': 'USER',
      'text': body['text'],
      'isInternal': false,
      'isRead': false,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    (ticketMessages[ticketId] ??= <Map<String, dynamic>>[]).add(message);
    return _ok(<String, dynamic>{'item': message}, status: 201);
  }

  http.Response? _ownActive(String id) {
    final Map<String, dynamic>? product = products[id];
    if (product == null) {
      return _error(404, 'PRODUCT_NOT_FOUND');
    }
    if (product['sellerId'] != meId) {
      return _error(403, 'FORBIDDEN');
    }
    if (product['status'] != 'ACTIVE') {
      return _error(409, 'VALIDATION');
    }
    return null;
  }

  http.Response _updateProduct(String id, Map<String, dynamic> body) {
    final http.Response? denied = _ownActive(id);
    if (denied != null) {
      return denied;
    }
    final Map<String, dynamic> product = products[id]!;
    for (final String key in <String>[
      'title',
      'description',
      'category',
      'price',
      'stock',
      'imageUrls',
      'locationLabel',
      'latitude',
      'longitude',
    ]) {
      if (body.containsKey(key)) {
        product[key] = body[key];
      }
    }
    product['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    return _ok(<String, dynamic>{
      'item': _productJson(product, detail: true),
    });
  }

  http.Response _archive(String id) {
    final http.Response? denied = _ownActive(id);
    if (denied != null) {
      return denied;
    }
    products[id]!['status'] = 'ARCHIVED';
    return _ok(<String, dynamic>{
      'item': _productJson(products[id]!, detail: true),
    });
  }

  http.Response _sold(String id) {
    final http.Response? denied = _ownActive(id);
    if (denied != null) {
      return denied;
    }
    products[id]!['status'] = 'SOLD';
    return _ok(<String, dynamic>{
      'item': _productJson(products[id]!, detail: true),
    });
  }

  http.Response _event(String id, Map<String, String> query) {
    if (!products.containsKey(id)) {
      return _error(404, 'PRODUCT_NOT_FOUND');
    }
    final bool recorded = products[id]!['sellerId'] != meId;
    analyticsEvents.add(<String, String>{
      'productId': id,
      'type': query['type'] ?? '',
      'source': query['source'] ?? '',
      'recorded': recorded ? '1' : '0',
    });
    return _ok(<String, dynamic>{'recorded': recorded}, status: 201);
  }

  http.Response _productStats(String id) {
    final Map<String, dynamic>? product = products[id];
    if (product == null) {
      return _error(404, 'PRODUCT_NOT_FOUND');
    }
    if (product['sellerId'] != meId) {
      return _error(403, 'FORBIDDEN');
    }
    int count(String type) {
      return analyticsEvents
          .where(
            (Map<String, String> event) =>
                event['productId'] == id &&
                event['type'] == type &&
                event['recorded'] == '1',
          )
          .length;
    }

    return _ok(<String, dynamic>{
      'item': <String, int>{
        'impressions': count('IMPRESSION'),
        'clicks': count('CLICK'),
        'inquiries': 0,
        'favorites': favorites.where((String saved) => saved == id).length,
      },
    });
  }

  http.Response _notificationList() {
    final List<Map<String, dynamic>> items = <Map<String, dynamic>>[
      ...notifications,
    ]..sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      return (b['createdAt'] as String? ?? '').compareTo(
        a['createdAt'] as String? ?? '',
      );
    });
    return _ok(<String, dynamic>{'items': items});
  }

  http.Response _markOne(String id) {
    for (final Map<String, dynamic> item in notifications) {
      if (item['id'] == id) {
        item['isRead'] = true;
        item['readAt'] = DateTime.now().toUtc().toIso8601String();
        return _ok(<String, dynamic>{'item': item});
      }
    }
    return _error(404, 'ROUTE_NOT_FOUND');
  }

  http.Response _markAll() {
    int count = 0;
    for (final Map<String, dynamic> item in notifications) {
      if (item['isRead'] != true) {
        item['isRead'] = true;
        count += 1;
      }
    }
    return _ok(<String, dynamic>{'count': count});
  }

  http.Response _prefs() {
    const List<String> keys = <String>[
      'chat',
      'verification',
      'reports',
      'support',
      'product',
      'system',
    ];
    return _ok(<String, dynamic>{
      'items': <Map<String, Object>>[
        for (final String key in keys)
          <String, Object>{
            'key': key,
            'enabled': notificationPrefs[key] ?? true,
          },
      ],
    });
  }

  http.Response _submitVerification(Map<String, dynamic> body) {
    if (verification != null && verification!['status'] != 'REJECTED') {
      return _error(409, 'VERIFICATION_EXISTS');
    }
    verification = <String, dynamic>{
      'id': 'verify-${_seq += 1}',
      'status': 'PENDING',
      'namaLengkap': body['namaLengkap'],
      'nim': body['nim'],
      'universitas': body['universitas'],
      'programStudi': body['programStudi'],
      'ktmImageUrl': body['ktmImageUrl'],
      'rejectionReason': '',
    };
    return _ok(<String, dynamic>{'item': verification}, status: 201);
  }

  http.Response _myVerification() {
    return _ok(<String, dynamic>{'item': verification});
  }

  http.Response _report(Map<String, dynamic> body) {
    final String id = 'report-${_seq += 1}';
    final Map<String, dynamic> item = <String, dynamic>{
      'id': id,
      'reportNo': 'RPT-$id',
      'reportedUserId': body['reportedUserId'],
      'reportedProductId': body['reportedProductId'],
      'category': body['category'],
      'description': body['description'],
      'status': 'OPEN',
    };
    reports.add(item);
    return _ok(<String, dynamic>{'item': item}, status: 201);
  }

  http.Response _closeTicket(String id) {
    final Map<String, dynamic>? ticket = tickets[id];
    if (ticket == null) {
      return _error(404, 'TICKET_NOT_FOUND');
    }
    ticket['status'] = 'CLOSED';
    return _ok(<String, dynamic>{'item': ticket});
  }

  http.Response _chatStream(String id) {
    if (!rooms.containsKey(id)) {
      return _error(404, 'CONVERSATION_NOT_FOUND');
    }
    final StringBuffer out = StringBuffer();
    for (final Map<String, dynamic> message
        in messages[id] ?? const <Map<String, dynamic>>[]) {
      out
        ..writeln('event: message')
        ..writeln('data: ${jsonEncode(message)}')
        ..writeln();
    }
    out
      ..writeln('event: done')
      ..writeln('data: {"ok":true}')
      ..writeln();
    return _sse(out.toString());
  }

  http.Response _chatWait(String id) {
    if (!rooms.containsKey(id)) {
      return _error(404, 'CONVERSATION_NOT_FOUND');
    }
    return _ok(<String, dynamic>{
      'outcome': 'waiting',
      'messages': <Map<String, dynamic>>[],
    });
  }

  http.Response _aiFailure() {
    final String code = aiErrorCode ?? 'AGENT_ERROR';
    return _error(code == 'AGENT_UNAVAILABLE' ? 503 : 502, code);
  }

  ({
    Map<String, dynamic> json,
    String answer,
    Map<String, dynamic>? listing,
  })?
  _aiPayload(Map<String, dynamic> body) {
    if (aiErrorCode != null) {
      return null;
    }
    final String id = body['conversation_id'] as String;
    final List<dynamic>? photos = body['imageUrls'] as List<dynamic>?;
    if (photos != null && photos.isNotEmpty) {
      final Map<String, dynamic> listing = <String, dynamic>{
        ...listingCard,
        'imageUrls': photos,
        'price': null,
        'stock': null,
      };
      final String answer =
          '${listingCard['title']}\n\n${listingCard['description']}';
      return (
        json: <String, dynamic>{
          'conversation_id': id,
          'answer': answer,
          'listing': listing,
        },
        answer: answer,
        listing: listing,
      );
    }
    final String answer = aiNeedsApproval
        ? 'AI butuh persetujuanmu sebelum melanjutkan.'
        : PlaceholderAiChat.replyAt(_aiReplies++);
    aiSessions[id] ??= <String, dynamic>{
      'id': id,
      'userId': meId,
      'title': body['message'],
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
    (aiHistory[id] ??= <Map<String, dynamic>>[])
      ..add(<String, dynamic>{'role': 'human', 'content': body['message']})
      ..add(<String, dynamic>{'role': 'ai', 'content': answer});
    return (
      json: <String, dynamic>{
        'conversation_id': id,
        'answer': answer,
        if (aiCallbacks.isNotEmpty) 'callbacks': aiCallbacks,
      },
      answer: answer,
      listing: null,
    );
  }

  String _aiFrames({
    required String answer,
    Map<String, dynamic>? listing,
  }) {
    final StringBuffer out = StringBuffer();
    void frame(String event, Object data) {
      out
        ..writeln('event: $event')
        ..writeln('data: ${jsonEncode(data)}')
        ..writeln();
    }

    if (aiThinking.isNotEmpty) {
      frame('thinking', <String, String>{'text': aiThinking});
    }
    if (answer.isNotEmpty && !aiNeedsApproval) {
      frame('token', <String, String>{'text': answer});
    }
    for (final Map<String, dynamic> callback in aiCallbacks) {
      frame('callback', callback);
    }
    if (aiNeedsApproval) {
      frame('interrupt', <String, Object>{
        'pending': <Map<String, Object>>[
          <String, Object>{
            'pending_tools': <Map<String, String>>[
              <String, String>{'name': 'send_chat_message'},
            ],
          },
        ],
      });
      frame('done', <String, Object>{'ok': true, 'awaitingApproval': true});
    } else {
      frame('done', <String, Object?>{
        'ok': true,
        'listing': ?listing,
      });
    }
    return out.toString();
  }

  http.Response _aiTurn(Map<String, dynamic> body) {
    final ({
      Map<String, dynamic> json,
      String answer,
      Map<String, dynamic>? listing,
    })?
    payload = _aiPayload(body);
    if (payload == null) {
      return _aiFailure();
    }
    return _ok(payload.json);
  }

  http.Response _aiStream(Map<String, dynamic> body) {
    final ({
      Map<String, dynamic> json,
      String answer,
      Map<String, dynamic>? listing,
    })?
    payload = _aiPayload(body);
    if (payload == null) {
      return _aiFailure();
    }
    return _sse(
      _aiFrames(answer: payload.answer, listing: payload.listing),
    );
  }

  http.Response _aiResume(Map<String, dynamic> body) {
    final bool approve = body['approve'] == true;
    final String id = body['conversation_id'] as String? ?? '';
    final String answer = approve ? 'Disetujui.' : 'Ditolak.';
    (aiHistory[id] ??= <Map<String, dynamic>>[]).add(<String, dynamic>{
      'role': 'ai',
      'content': answer,
    });
    return _ok(<String, dynamic>{
      'conversation_id': id,
      'answer': answer,
    });
  }

  http.Response _aiWait(String id) {
    return _ok(<String, dynamic>{
      'status': aiWaitStatus,
      'answer': aiWaitStatus == 'resolved' ? 'Sudah.' : '',
      'remainingS': 1,
      'conversation_id': id,
    });
  }

  // ------------------------------------------------------------- helpers ---

  static String? _iso(int millis) {
    return millis == 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            millis,
            isUtc: true,
          ).toIso8601String();
  }

  static http.Response _sse(String body) {
    return http.Response(
      body,
      200,
      headers: <String, String>{'content-type': 'text/event-stream'},
    );
  }

  static http.Response _ok(Map<String, dynamic> body, {int status = 200}) {
    return http.Response(
      jsonEncode(<String, dynamic>{'status': 'ok', ...body}),
      status,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }

  static http.Response _error(int status, String code) {
    return http.Response(
      jsonEncode(<String, dynamic>{
        'status': 'error',
        'code': code,
        'message': code,
      }),
      status,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }
}

/// @dev Silences "unused import" for drift's Value, used through the
/// fixtures' companions above.
// ignore: unused_element
const Value<int> _unused = Value<int>.absent();
