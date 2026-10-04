/// @title PlaceholderHelp
/// @notice Stand-in FAQ topics and support tickets until help is wired up.
/// @author Kosply-mobile
library;

import '../models/conversation.dart';
import '../models/help_topic.dart';
import '../models/seller.dart';
import '../models/support_ticket.dart';

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
