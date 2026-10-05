/// @title ProfileSettingScreen
/// @notice Edit photo, name, username, and seller bio.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_mode.dart';
import '../models/seller.dart';
import '../models/user_profile.dart';
import '../providers/account_mode_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/kosply_colors.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/seller_avatar.dart';

/// @title ProfileSettingScreen
/// @notice Profile editor opened from Settings or the top-bar avatar.
class ProfileSettingScreen extends ConsumerStatefulWidget {
  /// @notice Creates the profile setting screen.
  /// @return A new {ProfileSettingScreen} instance.
  const ProfileSettingScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/profile-setting';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const ProfileSettingScreen(),
      ),
    );
  }

  /// @notice Creates the mutable form state.
  /// @return The {_ProfileSettingScreenState} instance.
  @override
  ConsumerState<ProfileSettingScreen> createState() =>
      _ProfileSettingScreenState();
}

/// @title _ProfileSettingScreenState
/// @notice Holds photo and text fields until Simpan writes the provider.
class _ProfileSettingScreenState extends ConsumerState<ProfileSettingScreen> {
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _bio;
  late String _avatarPath;

  /// @notice Seeds the fields from the saved profile.
  /// @return void
  @override
  void initState() {
    super.initState();
    final UserProfile profile = ref.read(profileProvider);
    _name = TextEditingController(text: profile.name);
    _username = TextEditingController(text: profile.username);
    _bio = TextEditingController(text: profile.bio);
    _avatarPath = profile.avatarPath;
  }

  /// @notice Releases the field controllers.
  /// @return void
  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _addPhoto() {
    setState(() => _avatarPath = Seller.avatar);
  }

  void _save() {
    ref
        .read(profileProvider.notifier)
        .save(
          UserProfile(
            name: _name.text.trim(),
            username: _username.text.trim(),
            bio: _bio.text.trim(),
            avatarPath: _avatarPath,
          ),
        );
    Navigator.of(context).maybePop();
  }

  /// @notice Builds the profile form.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final bool isSeller = ref.watch(accountModeProvider) == AccountMode.seller;
    final Color onShell = KosplyColors.textPrimaryOf(context);
    final bool hasPhoto = _avatarPath.isNotEmpty;

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: PhosphorGlyph(PhosphorCode.arrowLeft, size: 20, color: onShell),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Profile setting',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: onShell,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Center(
            child: GestureDetector(
              key: const Key('profile-photo'),
              onTap: _addPhoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  hasPhoto
                      ? SellerAvatar(path: _avatarPath, size: 96)
                      : Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: KosplyColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: KosplyColors.outlineOf(context),
                            ),
                          ),
                          child: const Center(
                            child: PhosphorGlyph(
                              PhosphorCode.user,
                              size: 36,
                              color: KosplyColors.primary,
                            ),
                          ),
                        ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: KosplyColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: PhosphorGlyph(
                        PhosphorCode.plus,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _LabeledField(
            label: 'Nama',
            hint: 'Nama lengkap',
            controller: _name,
            fieldKey: const Key('profile-name'),
          ),
          const SizedBox(height: 16),
          _LabeledField(
            label: 'Username',
            hint: 'seller1',
            controller: _username,
            fieldKey: const Key('profile-username'),
          ),
          if (isSeller) ...[
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Bio',
              hint: 'Ceritakan barang yang kamu jual di kampus.',
              controller: _bio,
              fieldKey: const Key('profile-bio'),
              maxLines: 4,
            ),
          ],
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
                key: const Key('profile-save'),
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: KosplyColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Simpan',
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

/// @title _LabeledField
/// @notice Label stacked above an outlined text field.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.fieldKey,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final Key fieldKey;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KosplyColors.textPrimaryOf(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: KosplyColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KosplyColors.outlineOf(context)),
          ),
          child: TextField(
            key: fieldKey,
            controller: controller,
            maxLines: maxLines,
            cursorColor: KosplyColors.primary,
            style: TextStyle(
              fontSize: 14,
              color: KosplyColors.textPrimaryOf(context),
            ),
            decoration: InputDecoration(
              hintText: hint,
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
    );
  }
}
