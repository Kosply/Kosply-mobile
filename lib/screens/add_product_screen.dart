/// @title AddProductScreen
/// @notice Form for listing a new campus second-hand item.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/kosply_colors.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/phosphor_icons.dart';

/// @title AddProductScreen
/// @notice New listing form opened from the Jual plus button.
class AddProductScreen extends StatefulWidget {
  /// @notice Creates the add-product screen.
  /// @return A new {AddProductScreen} instance.
  const AddProductScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/add-product';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Creates the mutable form state.
  /// @return The {_AddProductScreenState} instance.
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

/// @title _AddProductScreenState
/// @notice Holds listing fields until a product API is wired up.
class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _quantity = TextEditingController(text: '1');
  final TextEditingController _description = TextEditingController();
  String _category = Product.categories.first;

  /// @notice Releases the field controllers.
  /// @return void
  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _location.dispose();
    _quantity.dispose();
    _description.dispose();
    super.dispose();
  }

  /// @notice Builds the stacked listing form.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final Color onShell = KosplyColors.textPrimaryOf(context);

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
            ),
            const SizedBox(height: 20),
            _LabeledField(
              label: 'Nama barang',
              hint: 'Meja belajar lipat',
              controller: _title,
              fieldKey: const Key('add-product-title'),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Harga',
              hint: 'Rp.375.000',
              controller: _price,
              fieldKey: const Key('add-product-price'),
              keyboardType: TextInputType.number,
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
            FilterChipBar(
              labels: Product.categories,
              selected: _category,
              onSelected: (String label) => setState(() => _category = label),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Deskripsi',
              hint: 'Kondisi barang, kelengkapan, dan cara ketemu di kampus.',
              controller: _description,
              fieldKey: const Key('add-product-description'),
              maxLines: 4,
            ),
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
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: KosplyColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pasang barang',
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
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final Key fieldKey;
  final TextInputType? keyboardType;
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
            keyboardType: keyboardType,
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
