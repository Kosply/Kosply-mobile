/// @title Location field
/// @notice One location input: current place first, then suggestions as the
/// seller types.
/// @author Kosply-mobile
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/device_location.dart';
import '../../../core/location/place_search.dart';
import '../../../providers/location/location_label_provider.dart';
import '../../../theme/colors/kosply_colors.dart';

/// @title LocationSuggestField
/// @notice Stacked location field with a suggestion list under it.
class LocationSuggestField extends ConsumerStatefulWidget {
  /// @notice Creates the field.
  /// @param controller Text the seller sees.
  /// @param onPin Called with the pin for the current text, or nulls when
  /// the text no longer matches a known place.
  /// @param fieldKey Key of the text field.
  /// @param label Caption above the field.
  /// @param hint Placeholder while the field is empty.
  /// @param prefill When true and the field is still empty, fill it from GPS.
  /// @param latitude Pin already stored for [controller]'s text.
  /// @param longitude Pin already stored for [controller]'s text.
  /// @return A new {LocationSuggestField} instance.
  const LocationSuggestField({
    required this.controller,
    required this.onPin,
    this.fieldKey,
    this.label = 'Lokasi',
    this.hint = 'Dekat gedung a',
    this.prefill = false,
    this.latitude,
    this.longitude,
    super.key,
  });

  /// @dev Text the seller sees.
  final TextEditingController controller;

  /// @dev Called when the pin for the current text changes.
  final void Function(double? latitude, double? longitude) onPin;

  /// @dev Key of the text field.
  final Key? fieldKey;

  /// @dev Caption above the field.
  final String label;

  /// @dev Placeholder while the field is empty.
  final String hint;

  /// @dev Fill an empty field from the device fix.
  final bool prefill;

  /// @dev Pin already stored for the starting text.
  final double? latitude;

  /// @dev Pin already stored for the starting text.
  final double? longitude;

  /// @notice Creates the suggestion state.
  /// @return The {_LocationSuggestFieldState} instance.
  @override
  ConsumerState<LocationSuggestField> createState() =>
      _LocationSuggestFieldState();
}

class _LocationSuggestFieldState extends ConsumerState<LocationSuggestField> {
  Timer? _debounce;
  int _generation = 0;
  bool _writing = false;
  String _pinnedText = '';
  String _originalText = '';
  double? _originalLatitude;
  double? _originalLongitude;
  List<PlaceHit> _hits = const <PlaceHit>[];

  @override
  void initState() {
    super.initState();
    _originalText = widget.controller.text.trim();
    final double? latitude = widget.latitude;
    final double? longitude = widget.longitude;
    if (latitude != null &&
        longitude != null &&
        (latitude.abs() > 0.000001 || longitude.abs() > 0.000001)) {
      _pinnedText = _originalText;
      _originalLatitude = latitude;
      _originalLongitude = longitude;
    }
    widget.controller.addListener(_onText);
    if (widget.prefill) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_prefill());
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  Future<void> _prefill() async {
    if (!mounted || widget.controller.text.trim().isNotEmpty) {
      return;
    }
    DeviceFix? fix = ref.read(deviceFixProvider);
    fix ??= await ref.read(deviceLocationProvider).currentFix();
    if (!mounted || widget.controller.text.trim().isNotEmpty) {
      return;
    }
    if (fix == null) {
      return;
    }
    ref.read(deviceFixProvider.notifier).remember(fix);
    final String label = fix.label.trim();
    if (label.isEmpty) {
      return;
    }
    _write(label);
    _pinnedText = label;
    _originalText = label;
    if (fix.hasPin) {
      _originalLatitude = fix.latitude;
      _originalLongitude = fix.longitude;
      widget.onPin(fix.latitude, fix.longitude);
    }
  }

  void _write(String text) {
    _writing = true;
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _writing = false;
  }

  void _onText() {
    if (_writing) {
      return;
    }
    final String text = widget.controller.text.trim();
    if (text == _pinnedText && _pinnedText.isNotEmpty) {
      if (_hits.isNotEmpty) {
        setState(() => _hits = const <PlaceHit>[]);
      }
      return;
    }
    if (text == _originalText && _originalLatitude != null) {
      _generation++;
      _debounce?.cancel();
      widget.onPin(_originalLatitude, _originalLongitude);
      if (_hits.isNotEmpty) {
        setState(() => _hits = const <PlaceHit>[]);
      }
      return;
    }
    widget.onPin(null, null);
    _generation++;
    _debounce?.cancel();
    if (text.length < 2) {
      setState(() => _hits = const <PlaceHit>[]);
      return;
    }
    final int generation = _generation;
    _debounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_search(text, generation));
    });
  }

  Future<void> _search(String text, int generation) async {
    final DeviceFix? fix = ref.read(deviceFixProvider);
    List<PlaceHit> hits = const <PlaceHit>[];
    try {
      hits = await ref
          .read(placeSearchProvider)
          .search(
            text,
            nearLatitude: fix != null && fix.hasPin ? fix.latitude : null,
            nearLongitude: fix != null && fix.hasPin ? fix.longitude : null,
          );
    } catch (_) {
      hits = const <PlaceHit>[];
    }
    if (!mounted || generation != _generation) {
      return;
    }
    if (widget.controller.text.trim() != text) {
      return;
    }
    setState(() => _hits = hits);
  }

  void _pick(PlaceHit hit) {
    _generation++;
    _debounce?.cancel();
    _write(hit.label);
    _pinnedText = hit.label.trim();
    _originalText = _pinnedText;
    _originalLatitude = hit.latitude;
    _originalLongitude = hit.longitude;
    widget.onPin(hit.latitude, hit.longitude);
    setState(() => _hits = const <PlaceHit>[]);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final Color onShell = KosplyColors.textPrimaryOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: onShell,
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
            key: widget.fieldKey,
            controller: widget.controller,
            maxLength: 200,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(200),
            ],
            buildCounter: (
              BuildContext context, {
              required int currentLength,
              required bool isFocused,
              required int? maxLength,
            }) => null,
            cursorColor: KosplyColors.primary,
            style: TextStyle(fontSize: 14, color: onShell),
            decoration: InputDecoration(
              hintText: widget.hint,
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
        if (_hits.isNotEmpty) ...[
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: KosplyColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KosplyColors.outlineOf(context)),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _hits.length; i++)
                  InkWell(
                    key: Key('location-suggestion-$i'),
                    onTap: () => _pick(_hits[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _hits[i].label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: onShell),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
