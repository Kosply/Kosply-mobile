/// @title SettingsScreen
/// @notice Profile-tab settings: account role, general, activity, support.
/// @dev Built for a campus second-hand marketplace. The heading switch flips
/// the same student account between pembeli and penjual. Dark mode is an
/// in-place toggle; Favorite and Analytic open their own screens. List
/// catalog lives on the Jual tab.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_mode.dart';
import '../providers/account_mode_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../theme/kosply_colors.dart';
import '../widgets/account_mode_switch.dart';
import '../widgets/phosphor_icons.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/settings_tile.dart';
import 'analytic_screen.dart';
import 'app_setting_screen.dart';
import 'contact_support_screen.dart';
import 'favorite_screen.dart';
import 'help_desk_screen.dart';
import 'profile_setting_screen.dart';

/// @title SettingsScreen
/// @notice Settings hub shown on the Profil tab.
class SettingsScreen extends ConsumerWidget {
  /// @notice Creates the settings screen.
  /// @param key Optional widget key.
  /// @return A new {SettingsScreen} instance.
  const SettingsScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/settings';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Builds the settings hub.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The settings screen widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AccountMode mode = ref.watch(accountModeProvider);
    final bool isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bool isSeller = mode == AccountMode.seller;

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      body: ListView(
        key: const Key('settings-scroll'),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Setting',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: KosplyColors.textPrimaryOf(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const AccountModeSwitch(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isSeller
                ? 'Mode penjual · jual barang kos ke mahasiswa di kampusmu.'
                : 'Mode pembeli · belanja barang bekas dari mahasiswa sekitar.',
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: KosplyColors.textSecondaryOf(context),
            ),
          ),
          const SizedBox(height: 24),
          _CategoryHeading('General'),
          const SizedBox(height: 10),
          SettingsSectionCard(
            children: [
              SettingsTile(
                icon: PhosphorCode.user,
                title: 'Profile setting',
                description: 'Nama, foto, dan data kampus buat transaksi antar mahasiswa.',
                onTap: () => ProfileSettingScreen.push(context),
              ),
              SettingsTile(
                icon: isDark ? PhosphorCode.sun : PhosphorCode.moon,
                title: 'Dark mode',
                description:
                    'Tampilan gelap, nyaman cek barang kos sampai malam.',
                onTap: () =>
                    ref.read(themeModeProvider.notifier).setDark(!isDark),
                trailing: Switch.adaptive(
                  value: isDark,
                  activeTrackColor: KosplyColors.primary,
                  onChanged: (bool value) {
                    ref.read(themeModeProvider.notifier).setDark(value);
                  },
                ),
              ),
              SettingsTile(
                icon: PhosphorCode.gear,
                title: 'setting',
                description: 'Notifikasi, privasi, dan preferensi akun Kosply.',
                onTap: () => AppSettingScreen.push(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _CategoryHeading('Aktivitas'),
          const SizedBox(height: 10),
          SettingsSectionCard(
            children: [
              SettingsTile(
                icon: PhosphorCode.heart,
                title: 'Favorite',
                description: 'Simpan barang bekas yang mau kamu ambil nanti.',
                onTap: () => FavoriteScreen.push(context),
              ),
              if (isSeller)
                SettingsTile(
                  icon: PhosphorCode.chartBar,
                  title: 'Analytic',
                  description:
                      'Pantau view, minat, dan performa jualan di kampus.',
                  onTap: () => AnalyticScreen.push(context),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _CategoryHeading('Support'),
          const SizedBox(height: 10),
          SettingsSectionCard(
            children: [
              SettingsTile(
                icon: PhosphorCode.question,
                title: 'Help desk',
                description:
                    'Panduan aman jual-beli barang kos antar mahasiswa.',
                onTap: () => HelpDeskScreen.push(context),
              ),
              SettingsTile(
                icon: PhosphorCode.headset,
                title: 'Contact support',
                description: 'Hubungi tim Kosply kalau transaksi bermasalah.',
                onTap: () => ContactSupportScreen.push(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// @dev Category title above a settings card.
class _CategoryHeading extends StatelessWidget {
  const _CategoryHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: KosplyColors.textPrimaryOf(context),
      ),
    );
  }
}
