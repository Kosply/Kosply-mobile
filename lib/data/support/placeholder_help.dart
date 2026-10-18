/// @title PlaceholderHelp
/// @notice Stand-in FAQ topics and support tickets until help is wired up.
/// @dev Also builds the seed rows the offline-first cache is filled with on
/// first launch.
/// @author Kosply-mobile
library;

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../models/catalog/seller.dart';
import '../../models/chat/conversation.dart';
import '../../models/support/help_topic.dart';
import '../../models/support/support_ticket.dart';
import '../shared/local_user.dart';

/// @title PlaceholderHelp
/// @notice Fake data source for Help desk and Contact support.
class PlaceholderHelp {
  // @dev Prevents instantiation of this utility holder.
  const PlaceholderHelp._();

  /// @dev Support agent shown on ticket rows and ticket chat.
  static const Seller agent = Seller(
    id: 'support',
    name: 'Kosply Support',
    avatarPath: Seller.avatar,
    activeLabel: 'aktif sekarang',
    bio: '',
  );

  /// @notice Common problems shared by Help desk and the ticket dropdown.
  /// @return FAQ topics in display order.
  static const List<HelpTopic> topics = <HelpTopic>[
    HelpTopic(
      title: 'Barang tidak sesuai deskripsi',
      answer:
          'Foto dan cek barang saat ketemu di kampus. Kalau beda jauh dari '
          'listing, batalkan transaksi dan laporkan lewat Contact support.',
    ),
    HelpTopic(
      title: 'Penjual tidak merespons',
      answer:
          'Tunggu 1x24 jam. Kalau tetap sepi, buka chat lain atau cari listing '
          'serupa. Kamu bisa buat ticket kalau sudah transfer di luar aplikasi.',
    ),
    HelpTopic(
      title: 'Pembeli batal ketemu',
      answer:
          'Kamu boleh jual lagi ke mahasiswa lain. Jangan kirim barang sebelum '
          'ketemu dan cek langsung di kampus.',
    ),
    HelpTopic(
      title: 'Masalah pembayaran / COD',
      answer:
          'Kosply masih COD di kampus. Jangan transfer ke rekening pribadi. '
          'Bayar setelah barang dicek di tempat yang ramai.',
    ),
    HelpTopic(
      title: 'Akun dan login',
      answer:
          'Pakai email kampus saat daftar. Lupa password lewat Reset password '
          'di layar login. Ticket ini kalau email kampus sudah tidak aktif.',
    ),
    HelpTopic(
      title: 'Lapor penipuan',
      answer:
          'Jangan lanjutkan pembayaran. Simpan chat dan foto, lalu buat ticket '
          'di Contact support supaya tim Kosply bisa meninjau akun tersebut.',
    ),
  ];

  /// @notice Titles of [topics], used by dropdowns.
  /// @return Topic titles in display order.
  static List<String> topicTitles() {
    return topics.map((HelpTopic topic) => topic.title).toList();
  }

  /// @notice Builds the FAQ rows seeded into the local cache.
  /// @param now UTC millis used as the reference time.
  /// @return Help-topic companions in display order.
  static List<HelpTopicsCompanion> topicRows({required int now}) {
    return <HelpTopicsCompanion>[
      for (int i = 0; i < topics.length; i++)
        HelpTopicsCompanion.insert(
          id: 'help-${i + 1}',
          title: topics[i].title,
          answer: topics[i].answer,
          sortOrder: Value<int>(i),
          updatedAt: Value<int>(now),
          lastFetched: Value<int>(now),
        ),
    ];
  }

  /// @notice Builds the ticket rows seeded into the local cache.
  /// @param now UTC millis used as the reference time.
  /// @return Ticket companions, newest activity first.
  static List<SupportTicketsCompanion> ticketRows({required int now}) {
    final List<SupportTicket> items = tickets();
    return <SupportTicketsCompanion>[
      for (int i = 0; i < items.length; i++)
        SupportTicketsCompanion.insert(
          id: items[i].id,
          ticketNo: Value<String>('KSP-${1001 + i}'),
          userId: const Value<String>(localUserId),
          category: Value<String>(items[i].topicTitle),
          status: Value<String>(
            items[i].status == SupportTicket.statusClose ? 'CLOSED' : 'OPEN',
          ),
          subject: Value<String>(items[i].title),
          description: Value<String>(items[i].preview),
          lastMessageAt: Value<int>(_lastMessageMillis(now: now, index: i)),
          createdAt: Value<int>(_lastMessageMillis(now: now, index: i)),
          backendUpdatedAt: Value<int>(_lastMessageMillis(now: now, index: i)),
          updatedAt: Value<int>(now),
          lastFetched: Value<int>(now),
        ),
    ];
  }

  /// @notice Builds the ticket bubbles seeded into the local cache.
  /// @dev The greeting and closing bubbles repeat {messagesFor} so the ticket
  /// chat renders the same copy. Tickets 1 and 4 end unread, matching the
  /// unread dots in the placeholder list.
  /// @param now UTC millis used as the reference time.
  /// @return Ticket-message companions, oldest first.
  static List<SupportMessagesCompanion> ticketMessageRows({required int now}) {
    final List<SupportMessagesCompanion> rows = <SupportMessagesCompanion>[];
    final List<SupportTicket> items = tickets();
    for (int i = 0; i < items.length; i++) {
      final SupportTicket item = items[i];
      final DateTime last = DateTime.fromMillisecondsSinceEpoch(
        _lastMessageMillis(now: now, index: i),
      );
      final bool greetingUnread = i == 3;
      final bool closingUnread = i == 0 || i == 3;
      rows.addAll(<SupportMessagesCompanion>[
        SupportMessagesCompanion.insert(
          id: '${item.id}-m0',
          ticketId: item.id,
          senderId: const Value<String>(localUserId),
          senderRole: const Value<String>('USER'),
          body: Value<String>(item.preview),
          isRead: const Value<bool>(true),
          createdAt: Value<int>(
            last.subtract(const Duration(minutes: 25)).millisecondsSinceEpoch,
          ),
        ),
        SupportMessagesCompanion.insert(
          id: '${item.id}-m1',
          ticketId: item.id,
          senderId: const Value<String>('support'),
          senderRole: const Value<String>('ADMIN'),
          senderName: const Value<String>('Kosply Support'),
          body: Value<String>(
            'Hai, terima kasih sudah menghubungi Kosply. Kami cek dulu '
            'laporan "${item.topicTitle}".',
          ),
          isRead: Value<bool>(!greetingUnread),
          readAt: Value<int>(
            greetingUnread ? 0 : last.millisecondsSinceEpoch,
          ),
          createdAt: Value<int>(
            last.subtract(const Duration(minutes: 10)).millisecondsSinceEpoch,
          ),
        ),
        SupportMessagesCompanion.insert(
          id: '${item.id}-m2',
          ticketId: item.id,
          senderId: const Value<String>('support'),
          senderRole: const Value<String>('ADMIN'),
          senderName: const Value<String>('Kosply Support'),
          body: Value<String>(
            item.status == SupportTicket.statusClose
                ? 'Ticket ini sudah ditutup. Buka ticket baru kalau masih '
                      'perlu bantuan.'
                : 'Boleh kirim foto atau cuplikan chat supaya kami bisa '
                      'bantu lebih cepat?',
          ),
          isRead: Value<bool>(!closingUnread),
          readAt: Value<int>(closingUnread ? 0 : last.millisecondsSinceEpoch),
          createdAt: Value<int>(last.millisecondsSinceEpoch),
        ),
      ]);
    }
    return rows;
  }

  /// @dev Activity offsets of the placeholder tickets.
  static const List<Duration> _ticketOffsets = <Duration>[
    Duration.zero,
    Duration(days: 1),
    Duration(days: 5),
    Duration(days: 30),
  ];

  /// @notice Reference time of one placeholder ticket.
  /// @dev The first ticket stays at 11:05 today so the list shows a stable
  /// clock label, mirroring the placeholder copy.
  /// @param now UTC millis used as the reference time.
  /// @param index Zero-based ticket slot.
  /// @return UTC millis of the ticket's last bubble.
  static int _lastMessageMillis({required int now, required int index}) {
    if (index == 0) {
      final DateTime local = DateTime.fromMillisecondsSinceEpoch(now);
      return DateTime(
        local.year,
        local.month,
        local.day,
        11,
        5,
      ).millisecondsSinceEpoch;
    }
    return now - _ticketOffsets[index].inMilliseconds;
  }

  /// @notice Looks a topic up by title.
  /// @param title Label taken from a dropdown.
  /// @return The matching topic, or the first topic.
  static HelpTopic topicByTitle(String title) {
    for (final HelpTopic topic in topics) {
      if (topic.title == title) {
        return topic;
      }
    }
    return topics.first;
  }

  /// @notice Placeholder tickets, newest activity first.
  /// @return The ticket list.
  static List<SupportTicket> tickets() {
    return <SupportTicket>[
      SupportTicket(
        id: 'ticket-1',
        title: 'Barang tidak sesuai deskripsi',
        preview: 'Foto barangnya beda dari listing, masih bisa retur?',
        timeLabel: '11:05',
        status: SupportTicket.statusOpen,
        topicTitle: 'Barang tidak sesuai deskripsi',
        unreadCount: 1,
      ),
      SupportTicket(
        id: 'ticket-2',
        title: 'Penjual tidak merespons',
        preview: 'Sudah 2 hari belum dibalas, listing masih tayang.',
        timeLabel: 'Kemarin',
        status: SupportTicket.statusOpen,
        topicTitle: 'Penjual tidak merespons',
      ),
      SupportTicket(
        id: 'ticket-3',
        title: 'Masalah pembayaran / COD',
        preview: 'Oke, ticket ini kita tutup ya. Terima kasih.',
        timeLabel: 'Sen',
        status: SupportTicket.statusClose,
        topicTitle: 'Masalah pembayaran / COD',
      ),
      SupportTicket(
        id: 'ticket-4',
        title: 'Lapor penipuan',
        preview: 'Minta transfer dulu ke DANA sebelum ketemu.',
        timeLabel: '12 Agu',
        status: SupportTicket.statusOpen,
        topicTitle: 'Lapor penipuan',
        unreadCount: 2,
      ),
    ];
  }

  /// @notice Looks a ticket up by id.
  /// @dev Falls back to the first ticket so a bad id still renders a screen.
  /// @param id Identifier taken from [SupportTicket.id].
  /// @return The matching ticket, or a fallback.
  static SupportTicket ticketById(String id) {
    final List<SupportTicket> items = tickets();
    for (final SupportTicket item in items) {
      if (item.id == id) {
        return item;
      }
    }
    return items.first;
  }

  /// @notice Placeholder bubbles for one ticket.
  /// @param ticketId Identifier taken from [SupportTicket.id].
  /// @return Messages oldest-first.
  static List<ChatMessage> messagesFor(String ticketId) {
    final SupportTicket ticket = ticketById(ticketId);
    return <ChatMessage>[
      ChatMessage(
        id: '$ticketId-m0',
        text: ticket.preview,
        isMine: true,
        timeLabel: '09:40',
      ),
      ChatMessage(
        id: '$ticketId-m1',
        text:
            'Hai, terima kasih sudah menghubungi Kosply. Kami cek dulu '
            'laporan "${ticket.topicTitle}".',
        isMine: false,
        timeLabel: '09:52',
      ),
      ChatMessage(
        id: '$ticketId-m2',
        text: ticket.status == SupportTicket.statusClose
            ? 'Ticket ini sudah ditutup. Buka ticket baru kalau masih perlu bantuan.'
            : 'Boleh kirim foto atau cuplikan chat supaya kami bisa bantu lebih cepat?',
        isMine: false,
        timeLabel: ticket.timeLabel,
      ),
    ];
  }
}
