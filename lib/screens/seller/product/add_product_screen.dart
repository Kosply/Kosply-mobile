/// @title AddProductScreen
/// @notice Form for listing a new campus second-hand item.
/// @author Kosply-mobile
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/catalog/listing_card.dart';
import '../../../models/catalog/listing_photos.dart';
import '../../../providers/catalog/listing_draft_provider.dart';
import '../../../providers/catalog/listing_photos_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';

/// @title AddProductScreen
/// @notice New listing form opened from the product camera's Lanjut button.
/// @dev Shows the photos captured in {ProductCameraScreen}, which stays below
/// this route so "Ubah foto" just pops back to it. On open the photos are
/// uploaded and the AI fills name, category and description from them
/// (`agent_spec/tables/listing.md`); those three fields are locked so the
/// listing always matches its photos. The seller types price, location and
/// quantity, then `POST /api/products` publishes it.
class AddProductScreen extends ConsumerStatefulWidget {
  /// @notice Creates the add-product screen.
  /// @return A new {AddProductScreen} instance.
  const AddProductScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/add-product';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return True when the listing was published.
  static Future<bool?> push(BuildContext context) {
    return Navigator.of(context).pushNamed<bool>(routeName);
  }

  /// @notice Creates the mutable form state.
  /// @return The {_AddProductScreenState} instance.
  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

/// @title _AddProductScreenState
/// @notice Holds the seller's fields and mirrors the AI card into the locked
/// ones.
class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _quantity = TextEditingController(text: '1');
  final TextEditingController _category = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String? _formError;

  @override
  void initState() {
    super.initState();
    // Provider writes are not allowed while the tree builds, so the upload
    // starts right after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  /// @notice Releases the field controllers.
  /// @return void
  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _location.dispose();
    _quantity.dispose();
    _category.dispose();
    _description.dispose();
    super.dispose();
  }

  void _start() {
    if (!mounted) {
      return;
    }
    final List<String> photos = ref.read(listingPhotosProvider).paths;
    unawaited(ref.read(listingDraftProvider.notifier).start(photos));
  }

  void _fill(ListingCard card) {
    _title.text = card.title;
    _category.text = card.category;
    _description.text = card.description;
  }

  /// @notice Reads digits only, so "Rp.375.000" and "375000" both work.
  /// @param text Field text.
  /// @return The integer, or null when there are no digits.
  int? _digits(String text) {
    final String digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  Future<void> _publish() async {
    final int? price = _digits(_price.text);
    final int stock = _digits(_quantity.text) ?? 0;
    if (price == null) {
      setState(() => _formError = 'Isi harga barang dulu.');
      return;
    }
    if (stock < 1) {
      setState(() => _formError = 'Kuantitas minimal 1.');
      return;
    }
    setState(() => _formError = null);
    final bool published = await ref
        .read(listingDraftProvider.notifier)
        .publish(price: price, stock: stock, location: _location.text.trim());
    if (published && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  /// @notice Builds the stacked listing form.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final Color onShell = KosplyColors.textPrimaryOf(context);
    final List<String> photos = ref.watch(listingPhotosProvider).paths;
    final ListingDraft draft = ref.watch(listingDraftProvider);
    ref.listen<ListingDraft>(listingDraftProvider, (
      ListingDraft? previous,
      ListingDraft next,
    ) {
      final ListingCard? card = next.card;
      if (card != null && previous?.card != card) {
        _fill(card);
      }
    });
    final bool locked = !draft.hasCard;
    final bool canPublish =
        draft.status == ListingDraftStatus.ready && !draft.isBusy;
    final String? error = _formError ?? draft.error;

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
          'Tambah barang',
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
            if (photos.isEmpty)
              Container(
                key: const Key('add-product-photo'),
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: KosplyColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KosplyColors.outlineOf(context)),
                ),
                child: const Center(
                  child: PhosphorGlyph(
                    PhosphorCode.plus,
                    size: 28,
                    color: KosplyColors.primary,
                  ),
                ),
              )
            else
              _PhotoStrip(
                paths: photos,
                onEdit: () => Navigator.of(context).maybePop(),
              ),
            const SizedBox(height: 12),
            _AiStatusBanner(
              draft: draft,
              hasPhotos: photos.isNotEmpty,
              onRetry: _start,
            ),
            const SizedBox(height: 20),
            _LabeledField(
              label: 'Nama barang',
              hint: locked ? 'Menunggu AI…' : 'Meja belajar lipat',
              controller: _title,
              fieldKey: const Key('add-product-title'),
              locked: true,
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Harga',
              hint: 'Rp.375.000',
              controller: _price,
              fieldKey: const Key('add-product-price'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Lokasi',
              hint: 'Dekat gedung a',
              controller: _location,
              fieldKey: const Key('add-product-location'),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Kuantitas',
              hint: '1',
              controller: _quantity,
              fieldKey: const Key('add-product-quantity'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Kategori',
              hint: locked ? 'Menunggu AI…' : 'Kategori',
              controller: _category,
              fieldKey: const Key('add-product-category'),
              locked: true,
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Deskripsi',
              hint: locked
                  ? 'Menunggu AI…'
                  : 'Kondisi barang, kelengkapan, dan cara ketemu di kampus.',
              controller: _description,
              fieldKey: const Key('add-product-description'),
              maxLines: 4,
              locked: true,
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(
                error,
                key: const Key('add-product-error'),
                style: const TextStyle(fontSize: 13, color: KosplyColors.error),
              ),
            ],
          ],
        ),
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
                key: const Key('add-product-submit'),
                onPressed: canPublish ? _publish : null,
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
                child: draft.status == ListingDraftStatus.publishing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Pasang barang',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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

/// @title _AiStatusBanner
/// @notice Says what the AI is doing with the photos, or why it stopped.
class _AiStatusBanner extends StatelessWidget {
  const _AiStatusBanner({
    required this.draft,
    required this.hasPhotos,
    required this.onRetry,
  });

  final ListingDraft draft;
  final bool hasPhotos;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final String message;
    switch (draft.status) {
      case ListingDraftStatus.idle:
        message = hasPhotos
            ? 'Menyiapkan foto…'
            : 'Ambil ${ListingPhotos.required} foto barang dulu, nanti AI '
                  'mengisi nama, kategori, dan deskripsi.';
      case ListingDraftStatus.uploading:
        message = 'Mengunggah foto ${draft.uploaded}/${draft.total}…';
      case ListingDraftStatus.filling:
        message = 'AI sedang membaca foto barang…';
      case ListingDraftStatus.ready:
      case ListingDraftStatus.publishing:
      case ListingDraftStatus.published:
        message =
            'Diisi AI dari foto. Nama, kategori, dan deskripsi dikunci; '
            'kamu tinggal isi harga, lokasi, dan kuantitas.';
      case ListingDraftStatus.failed:
        message = draft.error ?? 'AI belum bisa mengisi. Coba lagi.';
    }
    final bool failed = draft.status == ListingDraftStatus.failed;
    final bool working =
        draft.status == ListingDraftStatus.uploading ||
        draft.status == ListingDraftStatus.filling ||
        (draft.status == ListingDraftStatus.idle && hasPhotos);

    return Container(
      key: const Key('add-product-ai-status'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (failed ? KosplyColors.error : KosplyColors.primary).withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (working)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: KosplyColors.primary,
              ),
            )
          else
            PhosphorGlyph(
              PhosphorCode.brain,
              size: 18,
              color: failed ? KosplyColors.error : KosplyColors.primary,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: KosplyColors.textPrimaryOf(context),
              ),
            ),
          ),
          if (failed && hasPhotos)
            TextButton(
              key: const Key('add-product-retry'),
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: KosplyColors.primary,
              ),
              child: const Text('Coba lagi'),
            ),
        ],
      ),
    );
  }
}

/// @title _PhotoStrip
/// @notice Captured listing photos in a horizontal row, the first as cover.
class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.paths, required this.onEdit});

  final List<String> paths;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Foto (${paths.length}/${ListingPhotos.required})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KosplyColors.textPrimaryOf(context),
              ),
            ),
            const Spacer(),
            TextButton(
              key: const Key('add-product-edit-photos'),
              onPressed: onEdit,
              style: TextButton.styleFrom(
                foregroundColor: KosplyColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ubah foto',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: paths.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) => _PhotoTile(
              key: Key('add-product-photo-$index'),
              path: paths[index],
              isCover: index == 0,
            ),
          ),
        ),
      ],
    );
  }
}

/// @title _PhotoTile
/// @notice Square photo thumbnail; the cover gets an outline and badge.
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.path, required this.isCover, super.key});

  final String path;
  final bool isCover;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(12);

    return SizedBox(
      width: 104,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: radius,
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              cacheWidth: 320,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stack,
              ) => ColoredBox(color: KosplyColors.outlineOf(context)),
            ),
          ),
          if (isCover) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: KosplyColors.primary, width: 2),
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: KosplyColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Cover',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// @title _LabeledField
/// @notice Label stacked above an outlined text field.
/// @dev A [locked] field is filled by the AI and cannot be edited.
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.fieldKey,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.locked = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final Key fieldKey;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KosplyColors.textPrimaryOf(context),
              ),
            ),
            if (locked) ...[
              const SizedBox(width: 6),
              PhosphorGlyph(
                PhosphorCode.lockSimple,
                size: 12,
                color: KosplyColors.textSecondaryOf(context),
              ),
              const SizedBox(width: 4),
              Text(
                'Diisi AI',
                style: TextStyle(
                  fontSize: 11,
                  color: KosplyColors.textSecondaryOf(context),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: locked
                ? KosplyColors.outlineOf(context).withValues(alpha: 0.25)
                : KosplyColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KosplyColors.outlineOf(context)),
          ),
          child: TextField(
            key: fieldKey,
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: locked,
            enableInteractiveSelection: !locked,
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
