/// @title Verification screen
/// @notice Uploads the KTM photo. Name, NIM, campus, and major come from
/// onboarding, so this screen has no form.
/// @author Kosply-mobile
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/keys/storage_keys.dart';
import '../../../core/storage/providers/storage_providers.dart';
import '../../../data/account/verification_repository.dart';
import '../../../models/account/seller_verification.dart';
import '../../../models/account/user_profile.dart';
import '../../../providers/account/profile_provider.dart';
import '../../../providers/account/session_provider.dart';
import '../../../providers/catalog/listing_draft_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';
import 'ktm_camera_screen.dart';

/// @title VerificationScreen
/// @notice KTM upload step opened from the seller welcome card.
class VerificationScreen extends ConsumerStatefulWidget {
  /// @notice Creates the screen.
  /// @return A new {VerificationScreen} instance.
  const VerificationScreen({super.key});

  /// @dev Named route.
  static const routeName = '/verification';

  /// @notice Pushes this screen.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: routeName),
        builder: (_) => const VerificationScreen(),
      ),
    );
  }

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  String? _photoPath;
  String _nim = '';
  bool _busy = false;
  bool _nimReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNim();
    });
  }

  Future<void> _loadNim() async {
    final String stored =
        (await ref.read(secureStoreProvider).read(StorageKeys.authNim))
            ?.trim() ??
        '';
    if (!mounted) {
      return;
    }
    setState(() {
      _nim = stored;
      _nimReady = true;
    });
  }

  Future<void> _capture() async {
    final String? path = await KtmCameraScreen.push(context);
    if (path != null && mounted) {
      setState(() => _photoPath = path);
    }
  }

  /// @notice Campus fields already collected at sign-up.
  /// A rejected application wins, because that is what review already saw.
  ({String name, String nim, String universitas, String programStudi})
  _identity() {
    final UserProfile profile = ref.read(profileProvider);
    final String sessionName = ref.read(sessionProvider)?.displayName ?? '';
    String name = profile.name.trim().isEmpty
        ? sessionName.trim()
        : profile.name.trim();
    String nim = _nim.trim();
    String universitas = profile.universitas.trim();
    String programStudi = profile.programStudi.trim();
    final SellerVerification? prior = ref
        .read(sellerVerificationProvider)
        .asData
        ?.value;
    if (prior != null) {
      if (prior.namaLengkap.trim().isNotEmpty) {
        name = prior.namaLengkap.trim();
      }
      if (prior.nim.trim().isNotEmpty) {
        nim = prior.nim.trim();
      }
      if (prior.universitas.trim().isNotEmpty) {
        universitas = prior.universitas.trim();
      }
      if (prior.programStudi.trim().isNotEmpty) {
        programStudi = prior.programStudi.trim();
      }
    }
    return (
      name: name,
      nim: nim,
      universitas: universitas,
      programStudi: programStudi,
    );
  }

  bool _identityReady() {
    final record = _identity();
    return record.name.isNotEmpty &&
        record.nim.isNotEmpty &&
        record.universitas.isNotEmpty &&
        record.programStudi.isNotEmpty;
  }

  Future<void> _complete() async {
    final String? path = _photoPath;
    if (_busy || path == null) {
      return;
    }
    final record = _identity();
    if (record.name.isEmpty ||
        record.nim.isEmpty ||
        record.universitas.isEmpty ||
        record.programStudi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data kampus dari pendaftaran belum lengkap.'),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final String url = await ref
          .read(uploadRepositoryProvider)
          .uploadImage(path);
      await ref
          .read(verificationRepositoryProvider)
          .submit(
            namaLengkap: record.name,
            nim: record.nim,
            universitas: record.universitas,
            programStudi: record.programStudi,
            ktmImageUrl: url,
          );
      ref.invalidate(sellerVerificationProvider);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.userMessage)));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(profileProvider);
    ref.watch(sellerVerificationProvider);
    final String? path = _photoPath;
    final bool ready = path != null && _nimReady && _identityReady();
    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        title: const Text('Verifikasi kampus'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            key: const Key('upload-nim-card'),
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
                  if (path == null)
                    InkWell(
                      key: const Key('upload-nim-pick'),
                      onTap: _busy ? null : _capture,
                      customBorder: const CircleBorder(),
                      child: Container(
                        key: const Key('upload-nim-icon'),
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: KosplyColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const PhosphorGlyph(
                          PhosphorCode.uploadSimple,
                          key: Key('upload-nim-glyph'),
                          size: 28,
                          color: KosplyColors.primary,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      key: const Key('upload-nim-pick'),
                      onTap: _busy ? null : _capture,
                      child: ClipRRect(
                        key: const Key('ktm-preview'),
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 1.586,
                          child: Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (
                              BuildContext context,
                              Object error,
                              StackTrace? stack,
                            ) => const ColoredBox(color: Color(0xFFE7E5E4)),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    path == null
                        ? 'Unggah foto KTM. Nama dan NIM di kartu harus terbaca.'
                        : 'Cek foto KTM-nya. Ketuk foto kalau mau ambil ulang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: KosplyColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('upload-nim-complete'),
                      onPressed: ready && !_busy ? _complete : null,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: KosplyColors.primary,
                        disabledBackgroundColor: KosplyColors.primary
                            .withValues(alpha: 0.4),
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Complete',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
