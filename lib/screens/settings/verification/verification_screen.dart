/// @title Verification screen
/// @notice Submits the KTM application and shows its status.
/// @dev `GET /api/verifications/me` on open. Submit uploads the photo, then
/// `POST /api/verifications`. NIM collected at Google sign-up is sent here,
/// with the card photo the route requires.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/account/verification_repository.dart';
import '../../../models/account/seller_verification.dart';
import '../../../providers/account/session_provider.dart';
import '../../../providers/catalog/listing_draft_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import 'ktm_camera_screen.dart';

/// @dev The caller's application. Invalidated after a submit.
final sellerVerificationProvider =
    FutureProvider.autoDispose<SellerVerification?>((ref) {
      return ref.watch(verificationRepositoryProvider).mine();
    });

/// @title VerificationScreen
/// @notice Campus verification form.
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
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nim = TextEditingController();
  final TextEditingController _campus = TextEditingController();
  final TextEditingController _major = TextEditingController();
  String? _photoPath;
  bool _seeded = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _nim.dispose();
    _campus.dispose();
    _major.dispose();
    super.dispose();
  }

  void _seedOnce() {
    if (_seeded) {
      return;
    }
    _seeded = true;
    final String name = ref.read(sessionProvider)?.displayName ?? '';
    if (name.isNotEmpty) {
      _name.text = name;
    }
  }

  Future<void> _capture() async {
    final String? path = await KtmCameraScreen.push(context);
    if (path != null && mounted) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    if (_photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto KTM belum diambil.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final String url = await ref
          .read(uploadRepositoryProvider)
          .uploadImage(_photoPath!);
      await ref.read(verificationRepositoryProvider).submit(
        namaLengkap: _name.text.trim(),
        nim: _nim.text.trim(),
        universitas: _campus.text.trim(),
        programStudi: _major.text.trim(),
        ktmImageUrl: url,
      );
      ref.invalidate(sellerVerificationProvider);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.userMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _seedOnce();
    final AsyncValue<SellerVerification?> page = ref.watch(
      sellerVerificationProvider,
    );
    final SellerVerification? current = page.value;
    final bool locked = current != null && !current.status.contains('REJECT');
    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        title: const Text('Verifikasi kampus'),
      ),
      body: ListView(
        key: const Key('verification-scroll'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (current != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _statusLine(current),
                key: const Key('verification-status'),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: KosplyColors.textPrimaryOf(context),
                ),
              ),
            ),
          TextField(
            key: const Key('verification-name'),
            controller: _name,
            enabled: !locked,
            decoration: const InputDecoration(labelText: 'Nama lengkap'),
          ),
          TextField(
            key: const Key('verification-nim'),
            controller: _nim,
            enabled: !locked,
            decoration: const InputDecoration(labelText: 'NIM'),
          ),
          TextField(
            controller: _campus,
            enabled: !locked,
            decoration: const InputDecoration(labelText: 'Universitas'),
          ),
          TextField(
            controller: _major,
            enabled: !locked,
            decoration: const InputDecoration(labelText: 'Program studi'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            key: const Key('verification-photo'),
            onPressed: locked ? null : _capture,
            child: Text(_photoPath == null ? 'Ambil foto KTM' : 'Foto KTM siap'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('verification-send'),
            onPressed: locked || _busy ? null : _submit,
            child: const Text('Kirim verifikasi'),
          ),
        ],
      ),
    );
  }

  String _statusLine(SellerVerification item) {
    switch (item.status) {
      case 'APPROVED':
        return 'Terverifikasi sebagai penjual.';
      case 'PENDING':
        return 'Menunggu review.';
      case 'REJECTED':
        return item.rejectionReason.isEmpty
            ? 'Ditolak. Kamu bisa kirim ulang.'
            : 'Ditolak: ${item.rejectionReason}';
      default:
        return item.status;
    }
  }
}
