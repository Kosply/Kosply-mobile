/// @title InboxScreen
/// @notice Inbox tab: username search, category chips, and conversation rows.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../data/placeholder_inbox.dart';
import '../models/conversation.dart';
import '../theme/kosply_colors.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/searchbar.dart';
import '../widgets/seller_avatar.dart';
import 'chat_detail_screen.dart';

/// @title InboxScreen
/// @notice Inbox tab body.
class InboxScreen extends StatefulWidget {
  /// @notice Creates the inbox screen.
  /// @return A new {InboxScreen} instance.
  const InboxScreen({super.key});

  /// @dev Chip that lists every thread.
  static const String filterAll = 'Semua';

  /// @dev Chip that lists unread threads.
  static const String filterUnread = 'Belum dibaca';

  /// @dev Chip labels shown under the username search.
  static const List<String> categories = <String>[
    filterAll,
    filterUnread,
    'Penjual',
    'Pembeli',
  ];

  /// @notice Creates the mutable search state.
  /// @return The {_InboxScreenState} instance.
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

/// @title _InboxScreenState
/// @notice Holds the username query and selected category.
class _InboxScreenState extends State<InboxScreen> {
  String _query = '';
  String _category = InboxScreen.filterAll;

  List<Conversation> get _visible {
    final String needle = _query.trim().toLowerCase();
    Iterable<Conversation> items = PlaceholderInbox.conversations();
    if (needle.isNotEmpty) {
      items = items.where(
        (Conversation item) => item.peer.name.toLowerCase().contains(needle),
      );
    }
    if (_category == InboxScreen.filterUnread) {
      items = items.where((Conversation item) => item.hasUnread);
    } else if (_category != InboxScreen.filterAll) {
      items = items.where((Conversation item) => item.category == _category);
    }
    return items.toList();
  }

  /// @notice Builds the inbox list.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final List<Conversation> items = _visible;

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          KosplySearchbar(
            key: const Key('inbox-username-search'),
            hint: 'Cari username...',
            showFilter: false,
            onChanged: (String value) {
              setState(() => _query = value);
            },
          ),
          const SizedBox(height: 12),
          FilterChipBar(
            labels: InboxScreen.categories,
            selected: _category,
            onSelected: (String label) {
              setState(() => _category = label);
            },
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Tidak ada percakapan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: KosplyColors.textSecondaryOf(context),
                ),
              ),
            )
          else
            for (final Conversation item in items)
              _ConversationTile(item: item),
        ],
      ),
    );
  }
}

/// @title _ConversationTile
/// @notice Photo, username, preview, time, and unread fill.
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.item});

  final Conversation item;

  @override
  Widget build(BuildContext context) {
    final bool unread = item.hasUnread;
    final Color nameColor = KosplyColors.textPrimaryOf(context);
    final Color previewColor = unread
        ? nameColor
        : KosplyColors.textSecondaryOf(context);

    return InkWell(
      key: Key('conversation-${item.id}'),
      onTap: () => ChatDetailScreen.push(context, item.id),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SellerAvatar.seller(item.peer, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.peer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                      color: nameColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                      color: previewColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.timeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                    color: unread
                        ? KosplyColors.primary
                        : KosplyColors.textSecondaryOf(context),
                  ),
                ),
                const SizedBox(height: 8),
                if (unread)
                  Container(
                    key: Key('unread-${item.id}'),
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: KosplyColors.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 10, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
