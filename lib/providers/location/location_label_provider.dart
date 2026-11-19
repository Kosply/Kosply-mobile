/// @title Location label
/// @notice The place name shown in the shell pill, and the pin behind it.
/// @dev The splash asks for permission. [resolve] runs once per session,
/// from the home shell, and does not open that dialog again.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/location/device_location.dart';
import '../../core/location/place_search.dart';

/// @dev Platform GPS. Tests override this with [FixedDeviceLocation].
final deviceLocationProvider = Provider<DeviceLocation>(
  (ref) => PlatformDeviceLocation(),
);

/// @dev Place suggestions for the listing form. Tests override this with
/// [EmptyPlaceSearch].
final placeSearchProvider = Provider<PlaceSearch>(
  (ref) => const NominatimPlaceSearch(),
);

/// @title DeviceFixStore
/// @notice Holds the latest viewer pin for catalogue ordering.
class DeviceFixStore extends Notifier<DeviceFix?> {
  /// @notice Starts with no pin.
  /// @return Null until [remember] stores one.
  @override
  DeviceFix? build() => null;

  /// @notice Keeps [fix] when it has coordinates.
  /// @param fix Reading from the device or a test double.
  /// @return void
  void remember(DeviceFix? fix) {
    if (fix != null && fix.hasPin) {
      state = fix;
    }
  }
}

/// @dev Viewer pin. Null until Home (or the listing form) resolves GPS.
final deviceFixProvider = NotifierProvider<DeviceFixStore, DeviceFix?>(
  DeviceFixStore.new,
);

/// @title LocationLabel
/// @notice Holds the pill caption and asks for a fix at most once.
/// @dev A plain [Notifier] so the first frame is "Lokasi" and a later GPS
/// result cannot be overwritten by an unfinished async build.
class LocationLabel extends Notifier<String> {
  bool _asked = false;

  /// @notice Starts as a neutral caption until [resolve] runs.
  /// @return "Lokasi".
  @override
  String build() => 'Lokasi';

  /// @notice Asks the device for a place name the first time Home is shown.
  /// A pin from the same reading is published for the catalogue.
  /// @return Future completing when the pill has a caption.
  Future<void> resolve() async {
    if (_asked) {
      return;
    }
    _asked = true;
    state = 'Mencari lokasi...';
    final DeviceFix? fix = await ref.read(deviceLocationProvider).currentFix();
    if (!ref.mounted) {
      return;
    }
    ref.read(deviceFixProvider.notifier).remember(fix);
    final String text = fix?.label.trim() ?? '';
    state = text.isEmpty ? 'Lokasi' : text;
  }
}

/// @dev Pill caption for the signed-in shell.
final locationLabelProvider = NotifierProvider<LocationLabel, String>(
  LocationLabel.new,
);
