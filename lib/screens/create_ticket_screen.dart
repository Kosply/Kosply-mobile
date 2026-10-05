/// @title CreateTicketScreen
/// @notice New support ticket: heading plus the Help desk dropdown.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../data/placeholder_help.dart';
import '../theme/kosply_colors.dart';
import '../widgets/kosply_dropdown.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/section_heading.dart';

/// @title CreateTicketScreen
/// @notice Form opened from the Contact support plus button.
class CreateTicketScreen extends StatefulWidget {
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
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

/// @title _CreateTicketScreenState
/// @notice Holds the selected problem and the ticket message.
class _CreateTicketScreenState extends State<CreateTicketScreen> {
  String? _topic;
  final TextEditingController _message = TextEditingController();

  /// @notice Releases the message controller.
  /// @return void
  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  /// @notice Builds the create-ticket form.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
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
            items: PlaceholderHelp.topicTitles(),
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
                onPressed: () => Navigator.of(context).maybePop(),
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
    );
  }
}
