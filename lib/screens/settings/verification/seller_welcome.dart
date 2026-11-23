/// @title Seller welcome
/// @notice Gate shown instead of seller settings until campus review passes.
/// @dev One card, three states. No application or a rejection offers
/// Verifikasi. A pending application offers Refresh. A rejection also prints
/// the reviewer's reason under the explanation.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/account/verification_repository.dart';
import '../../../models/account/seller_verification.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';
import 'verification_screen.dart';

/// @title SellerWelcomeCard
/// @notice Centered welcome card for an unverified seller.
class SellerWelcomeCard extends ConsumerWidget {
  /// @notice Creates the card.
  /// @param application The caller's KTM application, still loading at first.
  /// @return A new {SellerWelcomeCard} instance.
  const SellerWelcomeCard({required this.application, super.key});

  /// @dev `GET /api/verifications/me`.
  final AsyncValue<SellerVerification?> application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SellerVerification? current = application.asData?.value;
    final bool waiting = application.isLoading && current == null;
    final bool pending = current?.isPending ?? false;
    final bool rejected = current?.isRejected ?? false;
    final String explanation = pending
        ? 'Pengajuan kamu sedang ditinjau. Refresh untuk cek keputusannya.'
        : 'Sebelum jual, verifikasi kartu mahasiswa kamu. Kami cek nama, NIM, dan foto KTM.';
    final String button = pending ? 'Refresh' : 'Verifikasi';

    return Material(
      key: const Key('seller-welcome-card'),
      color: KosplyColors.surfaceOf(context),
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KosplyColors.outlineOf(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: const Key('seller-welcome-icon'),
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: KosplyColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: PhosphorGlyph(
                pending ? PhosphorCode.clock : PhosphorCode.user,
                key: const Key('seller-welcome-glyph'),
                size: 28,
                color: KosplyColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              explanation,
              key: const Key('seller-welcome-copy'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: KosplyColors.textPrimaryOf(context),
              ),
            ),
            if (rejected) ...[
              const SizedBox(height: 10),
              Text(
                current!.rejectionReason.isEmpty
                    ? 'Pengajuan ditolak.'
                    : current.rejectionReason,
                key: const Key('seller-welcome-reason'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: KosplyColors.error,
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                key: const Key('seller-welcome-action'),
                onPressed: waiting
                    ? null
                    : () {
                        if (pending) {
                          ref.invalidate(sellerVerificationProvider);
                          return;
                        }
                        VerificationScreen.push(context);
                      },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: KosplyColors.primary,
                  disabledBackgroundColor: KosplyColors.primary.withValues(
                    alpha: 0.4,
                  ),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: waiting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        button,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
