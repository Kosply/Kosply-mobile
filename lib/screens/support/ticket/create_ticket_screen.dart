/// @title CreateTicketScreen
/// @notice New support ticket: heading plus the Help desk dropdown.
/// @dev "Kirim ticket" posts to `POST /api/support/tickets` (topic as the
/// subject) and opens the new ticket's thread in place of the form.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../models/support/help_topic.dart';
import '../../../providers/support/support_providers.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/ai/overlay/ai_overlay_layer.dart';
import '../../../widgets/common/forms/kosply_dropdown.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';
import '../../../widgets/common/headings/section_heading.dart';
import 'ticket_detail_screen.dart';

/// @title CreateTicketScreen
/// @notice Form opened from the Contact support plus button.
class CreateTicketScreen extends ConsumerStatefulWidget {
  /// @notice Creates the create-ticket screen.
  /// @return A new {CreateTicketScreen} instance.
  const CreateTicketScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/create-ticket';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Creates the mutable form state.
  /// @return The {_CreateTicketScreenState} instance.
  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

/// @title _CreateTicketScreenState
/// @notice Holds the selected problem and the ticket message.
class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  String? _topic;
  final TextEditingController _message = TextEditingController();
  bool _sending = false;

  /// @notice Releases the message controller.
  /// @return void
  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  /// @notice Opens the ticket, then replaces the form with its thread.
  /// @return Future completing when navigation starts.
  Future<void> _submit() async {
    final String? topic = _topic;
    final String message = _message.text.trim();
    if (_sending) {
      return;
    }
    if (topic == null || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih masalah dan tulis pesannya dulu.')),
      );
      return;
    }
    setState(() => _sending = true);
    final String ticketId;
    try {
      ticketId = await ref
          .read(supportRepositoryProvider)
          .openTicket(topic: topic, message: message);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
      return;
    }
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushReplacementNamed(TicketDetailScreen.routeName, arguments: ticketId);
  }

  /// @notice Builds the create-ticket form.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    ref.watch(helpTopicsSyncProvider);
    final List<HelpTopic> topics =
        ref.watch(helpTopicsProvider).value ?? const <HelpTopic>[];

    return RouteGapHost(
      gap: kBottomBarGap,
      child: Scaffold(
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
            'Buat ticket',
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
            const SectionHeading('Kategori masalah'),
            const SizedBox(height: 12),
            KosplyDropdown(
              key: const Key('create-ticket-dropdown'),
              items: <String>[
                for (final HelpTopic topic in topics) topic.title,
              ],
              value: _topic,
              hint: 'Pilih masalah umum',
              onChanged: (String value) {
                setState(() => _topic = value);
              },
            ),
            const SizedBox(height: 20),
            const SectionHeading('Pesan'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: KosplyColors.surfaceOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: KosplyColors.outlineOf(context)),
              ),
              child: TextField(
                key: const Key('create-ticket-message'),
                controller: _message,
                maxLines: 5,
                cursorColor: KosplyColors.primary,
                style: TextStyle(
                  fontSize: 14,
                  color: KosplyColors.textPrimaryOf(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Ceritakan kendalanya secara singkat.',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: KosplyColors.textSecondaryOf(context),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Material(
          color: KosplyColors.surfaceOf(context),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('create-ticket-submit'),
                  onPressed: _sending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: KosplyColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kirim ticket',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
