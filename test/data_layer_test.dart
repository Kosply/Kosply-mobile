/// @title Data layer tests
/// @notice Covers the offline-first cache: seeding and the repository
/// mappings every screen reads from.
/// @author Kosply-mobile
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:kosply_mobile/core/database/app_database.dart';
import 'package:kosply_mobile/data/account/account_repository.dart';
import 'package:kosply_mobile/data/catalog/catalog_repository.dart';
import 'package:kosply_mobile/data/chat/ai_chat_repository.dart';
import 'package:kosply_mobile/data/inbox/inbox_repository.dart';
import 'package:kosply_mobile/data/shared/app_seeder.dart';
import 'package:kosply_mobile/data/shared/price_labels.dart';
import 'package:kosply_mobile/data/shared/time_labels.dart';
import 'package:kosply_mobile/data/support/support_repository.dart';
import 'package:kosply_mobile/models/account/user_profile.dart';
import 'package:kosply_mobile/models/catalog/product.dart';
import 'package:kosply_mobile/models/chat/ai_thread.dart';
import 'package:kosply_mobile/models/chat/conversation.dart';
import 'package:kosply_mobile/models/support/help_topic.dart';
import 'package:kosply_mobile/models/support/support_ticket.dart';

/// @notice Offline-first cache checks.
/// @return void
void main() {
  late AppDatabase db;
  late CatalogRepository catalog;
  late AccountRepository account;
  late InboxRepository inbox;
  late SupportRepository support;
  late AiChatRepository aiChat;

  setUp(() async {
    db = AppDatabase.memory();
    catalog = CatalogRepository(dao: db.catalogDao);
    account = AccountRepository(dao: db.accountDao);
    inbox = InboxRepository(dao: db.inboxDao);
    support = SupportRepository(dao: db.supportDao);
    aiChat = AiChatRepository(dao: db.aiChatDao);
    await AppSeeder(
      catalog: catalog,
      inbox: inbox,
      support: support,
      aiChat: aiChat,
    ).seedIfEmpty();
  });

  tearDown(() => db.close());

  test('price and time labels follow the app copy', () {
    expect(priceLabel(375000), 'Rp.375.000');
    expect(priceLabel(45000), 'Rp.45.000');
    expect(priceLabel(1250000), 'Rp.1.250.000');

    final DateTime now = DateTime(2026, 8, 12, 15, 0);
    expect(timeLabelFor(now.millisecondsSinceEpoch, now: now), '15:00');
    expect(
      timeLabelFor(
        now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        now: now,
      ),
      'Kemarin',
    );
    expect(
      timeLabelFor(
        now.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
        now: now,
      ),
      'Jum',
    );
    expect(
      timeLabelFor(
        now.subtract(const Duration(days: 30)).millisecondsSinceEpoch,
        now: now,
      ),
      '13 Jul',
    );
    expect(
      activityLabelFor(
        now.subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
        now: now,
      ),
      'aktif 5 menit lalu',
    );
  });

  test('catalog seeds products with their seller and activity label', () async {
    final List<Product> products = await catalog.watchProducts().first;
    expect(products, hasLength(16));
    expect(products.first.id, 'product-0');
    expect(products.first.title, 'Meja belajar lipat');
    expect(products.first.price, 'Rp.375.000');
    expect(products.first.sellerName, 'seller1');
    expect(products.first.sellerActiveLabel, 'aktif 5 menit lalu');
    expect(products.first.quantity, 1);

    final Product? detail = await catalog.watchProduct('product-1').first;
    expect(detail, isNotNull);
    expect(detail!.sellerName, 'seller2');
    expect(detail.sellerActiveLabel, 'aktif 16 menit lalu');

    final List<Product> listed = await catalog
        .watchProductsBySeller('seller-3')
        .first;
    expect(listed, hasLength(4));
    expect(listed.every((Product item) => item.sellerId == 'seller-3'), isTrue);
  });

  test(
    'toggling a favorite writes the cache and streams the product',
    () async {
      expect(await catalog.watchFavoriteIds().first, isEmpty);

      await catalog.toggleFavorite('product-0');
      await catalog.toggleFavorite('product-1');

      final Set<String> ids = await catalog.watchFavoriteIds().first;
      expect(ids, <String>{'product-0', 'product-1'});

      final List<Product> saved = await catalog.watchFavoriteProducts().first;
      expect(saved.map((Product item) => item.id), <String>[
        'product-0',
        'product-1',
      ]);

      await catalog.toggleFavorite('product-0');
      final Set<String> next = await catalog.watchFavoriteIds().first;
      expect(next, <String>{'product-1'});
    },
  );

  test('account profile starts empty and persists a save', () async {
    expect(await account.watchProfile().first, const UserProfile());

    await account.saveProfile(
      const UserProfile(name: 'Fajar', username: 'fajar', bio: 'kos'),
    );
    final UserProfile saved = await account.watchProfile().first;
    expect(saved.name, 'Fajar');
    expect(saved.username, 'fajar');
    expect(saved.bio, 'kos');
  });

  test('inbox derives previews, time labels, and unread counts', () async {
    final List<Conversation> rows = await inbox.watchConversations().first;
    expect(rows, hasLength(4));
    expect(rows.first.id, 'seller-1');
    expect(rows.first.peer.name, 'seller1');
    expect(rows.first.preview, 'Meja masih available?');
    expect(rows.first.unreadCount, 1);
    expect(rows.first.category, 'Penjual');

    final List<ChatMessage> messages = await inbox
        .watchMessages('seller-1')
        .first;
    expect(messages, hasLength(3));
    expect(messages.first.isMine, isTrue);
    expect(messages.first.text, 'Hai seller1, barangnya masih ada?');
    expect(messages.last.text, 'Meja masih available?');

    final peer = await inbox.watchPeer('seller-2').first;
    expect(peer?.name, 'seller2');
  });

  test('support seeds the FAQ and derives ticket rows', () async {
    final List<HelpTopic> topics = await support.watchHelpTopics().first;
    expect(topics, hasLength(6));
    expect(topics.first.title, 'Barang tidak sesuai deskripsi');

    final List<SupportTicket> tickets = await support.watchTickets().first;
    expect(tickets, hasLength(4));
    expect(tickets.first.id, 'ticket-1');
    expect(tickets.first.status, SupportTicket.statusOpen);
    expect(tickets.first.topicTitle, 'Barang tidak sesuai deskripsi');
    expect(tickets.first.unreadCount, 1);

    final List<ChatMessage> messages = await support
        .watchTicketMessages('ticket-1')
        .first;
    expect(messages, hasLength(3));
    expect(
      messages[1].text,
      contains('Hai, terima kasih sudah menghubungi Kosply'),
    );
  });

  test('AI history hydrates and appends persist', () async {
    final List<AiThread> threads = await aiChat.threadsOnce();
    expect(threads, hasLength(4));
    expect(threads.first.id, 'ai-1');
    expect(threads.first.title, 'Cari meja belajar');
    expect(threads.first.messages, hasLength(2));

    await aiChat.persistThread(
      const AiThread(
        id: 'ai-new-1',
        title: 'Halo AI',
        preview: 'Lorem',
        timeLabel: 'Baru',
        messages: <AiMessage>[
          AiMessage(id: 'ai-new-1-h-1', text: 'Halo AI', isMine: true),
          AiMessage(id: 'ai-new-1-a-1', text: 'Lorem', isMine: false),
        ],
      ),
    );

    final List<AiThread> next = await aiChat.threadsOnce();
    expect(next, hasLength(5));
    expect(next.first.id, 'ai-new-1');
    expect(next.first.messages, hasLength(2));
  });
}
