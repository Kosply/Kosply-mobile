/// @title ContactSupportScreen
/// @notice Ticket inbox: search, create, status chips, and rows like Inbox.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../data/placeholder_help.dart';
import '../models/support_ticket.dart';
import '../theme/kosply_colors.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/searchbar.dart';
import '../widgets/seller_avatar.dart';
import 'create_ticket_screen.dart';
import 'ticket_detail_screen.dart';

/// @title ContactSupportScreen
/// @notice Contact support destination opened from Settings.
class ContactSupportScreen extends StatefulWidget {
  /// @notice Creates the contact support screen.
  /// @return A new {ContactSupportScreen} instance.
  const ContactSupportScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/contact-support';

  /// @dev Chip that lists every ticket.
  static const String filterAll = 'All';

  /// @dev Chip labels shown under the ticket search.
  static const List<String> categories = <String>[
    filterAll,
    SupportTicket.statusOpen,
    SupportTicket.statusClose,
  ];

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Creates the mutable search and filter state.
  /// @return The {_ContactSupportScreenState} instance.
  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

/// @title _ContactSupportScreenState
/// @notice Holds the ticket query and selected status chip.
class _ContactSupportScreenState extends State<ContactSupportScreen> {
  String _query = '';
  String _status = ContactSupportScreen.filterAll;

  List<SupportTicket> get _visible {
    final String needle = _query.trim().toLowerCase();
    Iterable<SupportTicket> items = PlaceholderHelp.tickets();
    if (needle.isNotEmpty) {
      items = items.where(
        (SupportTicket item) => item.title.toLowerCase().contains(needle),
      );
    }
    if (_status != ContactSupportScreen.filterAll) {
      items = items.where((SupportTicket item) => item.status == _status);
    }
    return items.toList();
  }

  /// @notice Builds the ticket list.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final List<SupportTicket> items = _visible;

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: PhosphorGlyph(
            PhosphorCode.arrowLeft,
            size: 20,
            color: KosplyColors.textPrimaryOf(context),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Contact support',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: KosplyColors.textPrimaryOf(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: KosplySearchbar(
                  key: const Key('ticket-search'),
                  hint: 'Cari ticket...',
                  showFilter: false,
                  onChanged: (String value) {
                    setState(() => _query = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              _CreateTicketButton(
                key: const Key('ticket-create'),
                onPressed: () => CreateTicketScreen.push(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilterChipBar(
            labels: ContactSupportScreen.categories,
            selected: _status,
            onSelected: (String label) {
              setState(() => _status = label);
            },
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Tidak ada ticket.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: KosplyColors.textSecondaryOf(context),
                ),
              ),
            )
          else
            for (final SupportTicket item in items) _TicketTile(item: item),
        ],
      ),
    );
  }
}

/// @title _CreateTicketButton
/// @notice Plus control tinted like Chat penjual at lower opacity.
class _CreateTicketButton extends StatelessWidget {
  const _CreateTicketButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: KosplyColors.primary.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: PhosphorGlyph(
              PhosphorCode.plus,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// @title _TicketTile
/// @notice Photo, ticket title, preview, time, and unread fill.
class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.item});

  final SupportTicket item;

  @override
  Widget build(BuildContext context) {
    final bool unread = item.hasUnread;
    final Color nameColor = KosplyColors.textPrimaryOf(context);
    final Color previewColor = unread
        ? nameColor
        : KosplyColors.textSecondaryOf(context);

    return InkWell(
      key: Key('ticket-${item.id}'),
      onTap: () => TicketDetailScreen.push(context, item.id),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SellerAvatar.seller(PlaceholderHelp.agent, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
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
                    key: Key('ticket-unread-${item.id}'),
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
