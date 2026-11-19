/// @title AddProductScreen
/// @notice Form for listing a new campus second-hand item.
/// @author Kosply-mobile
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/catalog/listing_photos.dart';
import '../../../providers/catalog/catalog_providers.dart';
import '../../../providers/catalog/listing_draft_provider.dart';
import '../../../providers/catalog/listing_photos_provider.dart';
import '../../../providers/catalog/product_form_fill_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/ai/overlay/ai_overlay_layer.dart';
import '../../../widgets/common/forms/kosply_dropdown.dart';
import '../../../widgets/common/forms/location_suggest_field.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';
import '../../../core/network/api_exception.dart';
import 'product_camera_screen.dart';

/// @title AddProductScreen
/// @notice New listing form opened from the Jual plus button.
/// @dev The seller types every field and adds photos from the camera. An
/// approved AI preview can fill nama, harga, deskripsi, and kategori. Pasang
/// barang still waits for the seller's tap.
class AddProductScreen extends ConsumerStatefulWidget {
  /// @notice Creates the add-product screen.
  /// @return A new {AddProductScreen} instance.
  const AddProductScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/add-product';

  /// @notice Pushes this screen onto the current route stack.
  /// @dev A typed [MaterialPageRoute] is required. The named-route table
  /// builds `Route<dynamic>`, and `pushNamed<bool>` then throws.
  /// @param context The build context.
  /// @return True when the listing was published.
  static Future<bool?> push(BuildContext context) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const AddProductScreen()),
    );
  }

  /// @notice Creates the mutable form state.
  /// @return The {_AddProductScreenState} instance.
  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

/// @title _AddProductScreenState
/// @notice Holds the seller's fields. An approved AI preview may fill four
/// of them. Pasang barang stays a tap.
class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _quantity = TextEditingController(text: '1');
  final TextEditingController _description = TextEditingController();
  List<String> _categories = const <String>[];
  String? _category;
  bool _categoriesReady = false;
  String? _formError;
  double? _latitude;
  double? _longitude;
  String? _wantedCategory;
  int _appliedFill = 0;
  late final AddProductPresence _presence;

  @override
  void initState() {
    super.initState();
    _presence = ref.read(addProductPresenceProvider);
    _presence.mounted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadCategories();
      _applyFill(ref.read(productFormFillProvider));
    });
  }

  /// @notice Releases the field controllers.
  /// @return void
  @override
  void dispose() {
    _presence.mounted = false;
    _title.dispose();
    _price.dispose();
    _location.dispose();
    _quantity.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final List<String> names = await ref
          .read(catalogRepositoryProvider)
          .categories();
      if (!mounted) {
        return;
      }
      setState(() {
        _categories = names;
        _categoriesReady = true;
        _selectCategory();
      });
    } on ApiException {
      if (mounted) {
        setState(() => _categoriesReady = true);
      }
    }
  }

  /// @notice Copies an approved preview into the four fields.
  /// @param fill Latest fill, or null when nothing was approved.
  /// @return void
  void _applyFill(ProductFormFill? fill) {
    if (fill == null || !mounted || fill.token == _appliedFill) {
      return;
    }
    _appliedFill = fill.token;
    _title.text = fill.title;
    _price.text = fill.price.toString();
    _description.text = fill.description;
    _wantedCategory = fill.category;
    setState(_selectCategory);
  }

  /// @notice Selects the dropdown row that matches the wanted category.
  /// @return void
  void _selectCategory() {
    final String? wanted = _wantedCategory?.trim().toLowerCase();
    if (wanted == null || wanted.isEmpty) {
      return;
    }
    for (final String name in _categories) {
      if (name.toLowerCase() == wanted) {
        _category = name;
        return;
      }
    }
  }

  void _openCamera() {
    unawaited(ProductCameraScreen.push(context));
  }

  /// @notice Reads digits only, so "Rp.375.000" and "375000" both work.
  /// @param text Field text.
  /// @return The integer, or null when there are no digits.
  int? _digits(String text) {
    final String digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  Future<void> _publish() async {
    final String title = _title.text.trim();
    final String description = _description.text.trim();
    final int? price = _digits(_price.text);
    final int stock = _digits(_quantity.text) ?? 0;
    final List<String> photos = ref.read(listingPhotosProvider).paths;
    if (title.isEmpty) {
      setState(() => _formError = 'Isi nama barang dulu.');
      return;
    }
    if (photos.length < ListingPhotos.required) {
      setState(
        () => _formError = 'Ambil ${ListingPhotos.required} foto barang dulu.',
      );
      return;
    }
    if (_category == null || _category!.isEmpty) {
      setState(() => _formError = 'Pilih kategori dulu.');
      return;
    }
    if (price == null) {
      setState(() => _formError = 'Isi harga barang dulu.');
      return;
    }
    if (stock < 1) {
      setState(() => _formError = 'Kuantitas minimal 1.');
      return;
    }
    if (description.isEmpty) {
      setState(() => _formError = 'Isi deskripsi dulu.');
      return;
    }
    setState(() => _formError = null);
    final bool published = await ref
        .read(listingDraftProvider.notifier)
        .publish(
          title: title,
          description: description,
          category: _category!,
          price: price,
          stock: stock,
          location: _location.text.trim(),
          photoPaths: photos,
          latitude: _latitude,
          longitude: _longitude,
        );
    if (published && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  /// @notice Builds the listing form.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    ref.listen<ProductFormFill?>(productFormFillProvider, (
      ProductFormFill? previous,
      ProductFormFill? next,
    ) {
      _applyFill(next);
    });
    final Color onShell = KosplyColors.textPrimaryOf(context);
    final List<String> photos = ref.watch(listingPhotosProvider).paths;
    final ListingDraft draft = ref.watch(listingDraftProvider);
    final bool busy = draft.isBusy;
    final String? error = _formError ?? draft.error;

    return RouteGapHost(
      gap: kBottomBarGap,
      child: PopScope(
        canPop: !busy,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: KosplyColors.backgroundOf(context),
          appBar: AppBar(
            backgroundColor: KosplyColors.backgroundOf(context),
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              key: const Key('add-product-back'),
              icon: PhosphorGlyph(
                PhosphorCode.arrowLeft,
                size: 20,
                color: onShell,
              ),
              onPressed: busy ? null : () => Navigator.of(context).maybePop(),
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
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('add-product-photo'),
                      onTap: busy ? null : _openCamera,
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: KosplyColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: KosplyColors.outlineOf(context),
                          ),
                        ),
                        child: const Center(
                          child: PhosphorGlyph(
                            PhosphorCode.plus,
                            size: 28,
                            color: KosplyColors.primary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  _PhotoStrip(
                    paths: photos,
                    onEdit: busy ? () {} : _openCamera,
                  ),
                const SizedBox(height: 20),
                _LabeledField(
                  label: 'Nama barang',
                  hint: 'Meja belajar lipat',
                  controller: _title,
                  fieldKey: const Key('add-product-title'),
                  maxLength: 80,
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
                LocationSuggestField(
                  controller: _location,
                  fieldKey: const Key('add-product-location'),
                  prefill: true,
                  onPin: (double? latitude, double? longitude) {
                    _latitude = latitude;
                    _longitude = longitude;
                  },
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
                Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KosplyColors.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 8),
                KeyedSubtree(
                  key: const Key('add-product-category'),
                  child: KosplyDropdown(
                    items: _categories,
                    value: _category,
                    hint: _categoriesReady
                        ? 'Pilih kategori'
                        : 'Memuat kategori…',
                    onChanged: (String next) =>
                        setState(() => _category = next),
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Deskripsi',
                  hint: 'Kondisi, kelengkapan, dan kekurangan.',
                  controller: _description,
                  fieldKey: const Key('add-product-description'),
                  minLines: 4,
                  maxLines: 12,
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    error,
                    key: const Key('add-product-error'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: KosplyColors.error,
                    ),
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
                    onPressed: busy ? null : _publish,
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
                    child: busy
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
        ),
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
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.fieldKey,
    this.keyboardType,
    this.inputFormatters,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final Key fieldKey;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? minLines;
  final int maxLines;
  final int? maxLength;

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
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: maxLength,
            buildCounter: (
              BuildContext context, {
              required int currentLength,
              required bool isFocused,
              required int? maxLength,
            }) => null,
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
