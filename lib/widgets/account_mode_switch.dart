/// @title AccountModeSwitch
/// @notice Compact Pembeli / Penjual control shown next to the Settings
/// heading.
/// @dev One student account, two roles: shop for kos items or list them.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_mode.dart';
import '../providers/account_mode_provider.dart';
import '../theme/kosply_colors.dart';

/// @title AccountModeSwitch
/// @notice Segmented buyer / seller switch.
class AccountModeSwitch extends ConsumerWidget {
  /// @notice Creates the role switch.
  /// @return A new {AccountModeSwitch} instance.
  const AccountModeSwitch({super.key});

  /// @notice Builds the pill control.
  /// @param context The build context.
  /// @param ref Riverpod handle.
  /// @return The switch widget.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AccountMode mode = ref.watch(accountModeProvider);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: KosplyColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KosplyColors.outlineOf(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'Pembeli',
            selected: mode == AccountMode.buyer,
            onTap: () => ref
                .read(accountModeProvider.notifier)
                .setMode(AccountMode.buyer),
          ),
          _Segment(
            label: 'Penjual',
            selected: mode == AccountMode.seller,
            onTap: () => ref
                .read(accountModeProvider.notifier)
                .setMode(AccountMode.seller),
          ),
        ],
      ),
    );
  }
}

/// @dev One segment of the role switch.
class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? KosplyColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : KosplyColors.textSecondaryOf(context),
          ),
        ),
      ),
    );
  }
}
