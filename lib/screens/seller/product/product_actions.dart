/// @title Listing actions
/// @notice Edit, mark sold, and archive for a product the seller owns.
/// @dev Writes go to `PATCH /api/products/:id`, `PATCH /:id/sold`, and
/// `DELETE /:id`.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/catalog/catalog_repository.dart';
import '../../../models/catalog/product.dart';
import '../../../providers/catalog/catalog_providers.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/forms/location_suggest_field.dart';

/// @notice Opens the owner menu and runs the chosen write.
/// @param context The build context.
/// @param ref Riverpod handle.
/// @param product Listing being managed.
/// @return Future completing when the menu closes. True when the listing
/// left the catalogue (sold or archived).
Future<bool> showListingActions(
  BuildContext context,
  WidgetRef ref,
  Product product,
) async {
  final String? action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: KosplyColors.backgroundOf(context),
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('listing-edit'),
              title: const Text('Ubah'),
              onTap: () => Navigator.of(context).pop('edit'),
            ),
            ListTile(
              key: const Key('listing-sold'),
              title: const Text('Tandai terjual'),
              onTap: () => Navigator.of(context).pop('sold'),
            ),
            ListTile(
              key: const Key('listing-archive'),
              title: const Text('Arsipkan'),
              onTap: () => Navigator.of(context).pop('archive'),
            ),
          ],
        ),
      );
    },
  );
  if (action == null || !context.mounted) {
    return false;
  }
  final CatalogRepository repo = ref.read(catalogRepositoryProvider);
  try {
    switch (action) {
      case 'edit':
        final NewListing? next = await _edit(context, product);
        if (next == null) {
          return false;
        }
        await repo.updateListing(product.id, next);
        return false;
      case 'sold':
        if (!await _confirm(context, 'Tandai barang ini terjual?')) {
          return false;
        }
        await repo.markSold(product.id);
        return true;
      case 'archive':
        if (!await _confirm(context, 'Arsipkan barang ini?')) {
          return false;
        }
        await repo.archiveListing(product.id);
        return true;
    }
  } on ApiException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.userMessage)));
    }
  }
  return false;
}

Future<bool> _confirm(BuildContext context, String title) async {
  final bool? yes = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            key: const Key('listing-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ya'),
          ),
        ],
      );
    },
  );
  return yes ?? false;
}

Future<NewListing?> _edit(BuildContext context, Product product) {
  return showDialog<NewListing>(
    context: context,
    builder: (BuildContext context) => _EditListingDialog(product: product),
  );
}

class _EditListingDialog extends StatefulWidget {
  const _EditListingDialog({required this.product});

  final Product product;

  @override
  State<_EditListingDialog> createState() => _EditListingDialogState();
}

class _EditListingDialogState extends State<_EditListingDialog> {
  late final TextEditingController _title = TextEditingController(
    text: widget.product.title,
  );
  late final TextEditingController _price = TextEditingController(
    text: '${widget.product.priceValue}',
  );
  late final TextEditingController _stock = TextEditingController(
    text: '${widget.product.quantity}',
  );
  late final TextEditingController _category = TextEditingController(
    text: widget.product.category,
  );
  late final TextEditingController _location = TextEditingController(
    text: widget.product.location,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.product.description,
  );
  late double? _latitude = _storedPin(widget.product.latitude);
  late double? _longitude = _storedPin(widget.product.longitude);

  double? _storedPin(double value) => value.abs() > 0.000001 ? value : null;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _stock.dispose();
    _category.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    final String title = _title.text.trim();
    final String description = _description.text.trim();
    final int? price = int.tryParse(_price.text.trim());
    final int? stock = int.tryParse(_stock.text.trim());
    if (title.isEmpty ||
        description.isEmpty ||
        price == null ||
        stock == null) {
      return;
    }
    Navigator.of(context).pop(
      NewListing(
        title: title,
        description: description,
        category: _category.text.trim(),
        price: price,
        stock: stock,
        imageUrls: widget.product.gallery.isEmpty
            ? <String>[
                if (widget.product.imagePath.startsWith('http'))
                  widget.product.imagePath,
              ]
            : widget.product.gallery
                  .where((String path) => path.startsWith('http'))
                  .toList(),
        locationLabel: _location.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        includeCoordinates: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle fieldStyle = TextStyle(
      fontSize: 16,
      color: KosplyColors.textPrimaryOf(context),
    );
    return AlertDialog(
      title: const Text('Ubah barang'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('edit-title'),
              controller: _title,
              cursorColor: KosplyColors.primary,
              style: fieldStyle,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              key: const Key('edit-price'),
              controller: _price,
              keyboardType: TextInputType.number,
              cursorColor: KosplyColors.primary,
              style: fieldStyle,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),
            TextField(
              controller: _stock,
              keyboardType: TextInputType.number,
              cursorColor: KosplyColors.primary,
              style: fieldStyle,
              decoration: const InputDecoration(labelText: 'Stok'),
            ),
            TextField(
              controller: _category,
              cursorColor: KosplyColors.primary,
              style: fieldStyle,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            LocationSuggestField(
              controller: _location,
              latitude: _latitude,
              longitude: _longitude,
              onPin: (double? latitude, double? longitude) {
                _latitude = latitude;
                _longitude = longitude;
              },
            ),
            TextField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              cursorColor: KosplyColors.primary,
              style: fieldStyle,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          key: const Key('edit-save'),
          onPressed: _save,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
