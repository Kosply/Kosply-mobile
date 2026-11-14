/// @title Report sheet
/// @notice Files `POST /api/reports` against a product, a seller, or both.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../data/reports/report_repository.dart';
import '../../theme/colors/kosply_colors.dart';

/// @notice Opens the report sheet.
/// @param context The build context.
/// @param productId Product being reported, when the sheet was opened from one.
/// @param userId Seller being reported, when the sheet was opened from a profile.
/// @return Future completing when the sheet closes.
Future<void> showReportSheet(
  BuildContext context, {
  String? productId,
  String? userId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: KosplyColors.backgroundOf(context),
    builder: (BuildContext context) {
      return _ReportSheet(productId: productId, userId: userId);
    },
  );
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({this.productId, this.userId});

  final String? productId;
  final String? userId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  static const List<(String, String)> _categories = <(String, String)>[
    ('PENIPUAN', 'Penipuan'),
    ('BARANG_PALSU', 'Barang palsu'),
    ('BARANG_TIDAK_SESUAI', 'Barang tidak sesuai'),
    ('HARGA_MENYESATKAN', 'Harga menyesatkan'),
    ('KONTEN_TIDAK_PANTAS', 'Konten tidak pantas'),
    ('SPAM', 'Spam'),
    ('LAINNYA', 'Lainnya'),
  ];

  String _category = 'PENIPUAN';
  final TextEditingController _description = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final String text = _description.text.trim();
    if (text.isEmpty || _busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(reportRepositoryProvider).file(
        reportedProductId: widget.productId,
        reportedUserId: widget.userId,
        category: _category,
        description: text,
      );
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.userMessage)),
        );
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan terkirim.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Laporkan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: KosplyColors.textPrimaryOf(context),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('report-category'),
            initialValue: _category,
            items: <DropdownMenuItem<String>>[
              for (final (String code, String label) in _categories)
                DropdownMenuItem<String>(value: code, child: Text(label)),
            ],
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _category = value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('report-description'),
            controller: _description,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Ceritakan apa yang terjadi',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('report-send'),
            onPressed: _busy ? null : _send,
            child: const Text('Kirim laporan'),
          ),
        ],
      ),
    );
  }
}
