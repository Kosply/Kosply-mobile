/// @title AppSettingScreen
/// @notice Account setting: profile, notifications, password, logout.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_settings.dart';
import '../models/user_profile.dart';
import '../providers/notification_settings_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/kosply_colors.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/seller_avatar.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_tile.dart';
import 'forgot_password_screen.dart';
import 'profile_setting_screen.dart';
import 'splash_screen.dart';

/// @title AppSettingScreen
/// @notice Destination opened from the General {setting} row.
class AppSettingScreen extends ConsumerWidget {
  /// @notice Creates the account setting screen.
  /// @return A new {AppSettingScreen} instance.
  const AppSettingScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/setting';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const AppSettingScreen(),
      ),
    );
  }

  /// @notice Builds the account setting body.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color onShell = KosplyColors.textPrimaryOf(context);
    final UserProfile profile = ref.watch(profileProvider);
    final NotificationSettings notes = ref.watch(notificationSettingsProvider);
    final bool personalized = notes.isPersonalized;
    final String modeLabel = personalized ? 'Personalisasi' : 'All';

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
          'setting',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: onShell,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSectionCard(
              children: [
                _ProfileRow(
                  profile: profile,
                  onTap: () => ProfileSettingScreen.push(context),
                ),
                SettingsTile(
                  icon: PhosphorCode.bell,
                  title: 'Notification',
                  description: 'Atur notifikasi akun kampusmu.',
                  trailing: _NotifyModeDropdown(
                    value: modeLabel,
                    onChanged: (String label) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .setMode(
                            label == 'Personalisasi'
                                ? NotificationMode.personalized
                                : NotificationMode.all,
                          );
                    },
                  ),
                ),
                if (personalized)
                  _channelTile(
                    icon: PhosphorCode.megaphone,
                    title: 'Iklan',
                    description: 'Promo listing dan iklan kampus.',
                    value: notes.ads,
                    fieldKey: const Key('notify-iklan'),
                    onChanged: (bool value) => ref
                        .read(notificationSettingsProvider.notifier)
                        .setAds(value),
                  ),
                if (personalized)
                  _channelTile(
                    icon: PhosphorCode.chatCircle,
                    title: 'Message',
                    description: 'Chat dari pembeli atau penjual.',
                    value: notes.message,
                    fieldKey: const Key('notify-message'),
                    onChanged: (bool value) => ref
                        .read(notificationSettingsProvider.notifier)
                        .setMessage(value),
                  ),
                if (personalized)
                  _channelTile(
                    icon: PhosphorCode.envelope,
                    title: 'New message',
                    description: 'Thread baru masuk ke inbox.',
                    value: notes.newMessage,
                    fieldKey: const Key('notify-new-message'),
                    onChanged: (bool value) => ref
                        .read(notificationSettingsProvider.notifier)
                        .setNewMessage(value),
                  ),
                if (personalized)
                  _channelTile(
                    icon: PhosphorCode.bell,
                    title: 'Promo',
                    description: 'Diskon dan flash sale kampus.',
                    value: notes.promo,
                    fieldKey: const Key('notify-promo'),
                    onChanged: (bool value) => ref
                        .read(notificationSettingsProvider.notifier)
                        .setPromo(value),
                  ),
                if (personalized)
                  _channelTile(
                    icon: PhosphorCode.package,
                    title: 'Transaksi',
                    description: 'Update order dan pembayaran.',
                    value: notes.transaction,
                    fieldKey: const Key('notify-transaction'),
                    onChanged: (bool value) => ref
                        .read(notificationSettingsProvider.notifier)
                        .setTransaction(value),
                  ),
                SettingsTile(
                  icon: PhosphorCode.lockSimple,
                  title: 'Ganti password',
                  description: 'Ubah kata sandi akun kampusmu.',
                  onTap: () => ForgotPasswordScreen.push(context),
                ),
                SettingsTile(
                  key: const Key('setting-logout'),
                  icon: PhosphorCode.signOut,
                  title: 'Log out',
                  description: 'Keluar dari akun Kosply.',
                  onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    SplashScreen.routeName,
                    (Route<dynamic> route) => false,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PhosphorGlyph(
                        PhosphorCode.signOut,
                        size: 16,
                        color: KosplyColors.error,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'logout',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: KosplyColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SettingsTile _channelTile({
    required int icon,
    required String title,
    required String description,
    required bool value,
    required Key fieldKey,
    required ValueChanged<bool> onChanged,
  }) {
    return SettingsTile(
      icon: icon,
      title: title,
      description: description,
      onTap: () => onChanged(!value),
      trailing: Switch.adaptive(
        key: fieldKey,
        value: value,
        activeTrackColor: KosplyColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}

/// @title _NotifyModeDropdown
/// @notice Compact All / Personalisasi select used in place of the caret.
class _NotifyModeDropdown extends StatelessWidget {
  const _NotifyModeDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const List<String> _items = <String>['All', 'Personalisasi'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          key: const Key('notify-mode'),
          isDense: true,
          isExpanded: true,
          value: value,
          iconEnabledColor: KosplyColors.textSecondaryOf(context),
          dropdownColor: KosplyColors.surfaceOf(context),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KosplyColors.textPrimaryOf(context),
          ),
          items: [
            for (final String item in _items)
              DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (String? next) {
            if (next != null) {
              onChanged(next);
            }
          },
        ),
      ),
    );
  }
}

/// @title _ProfileRow
/// @notice Photo, name, and username with a trailing caret.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.profile, required this.onTap});

  final UserProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String name = profile.name.isEmpty ? 'Nama' : profile.name;
    final String username = profile.username.isEmpty
        ? 'username'
        : (profile.username.startsWith('@')
              ? profile.username
              : '@${profile.username}');

    return InkWell(
      key: const Key('setting-profile'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            profile.hasPhoto
                ? SellerAvatar(path: profile.avatarPath, size: 48)
                : Container(
                    width: 48,
                    height: 48,
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
                        size: 22,
                        color: KosplyColors.primary,
                      ),
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KosplyColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: KosplyColors.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PhosphorGlyph(
              PhosphorCode.caretRight,
              size: 16,
              color: KosplyColors.textSecondaryOf(context),
            ),
          ],
        ),
      ),
    );
  }
}
