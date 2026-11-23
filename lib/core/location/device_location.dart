/// @title Device location
/// @notice Turns the phone's position into a short place name and a pin.
/// @dev The splash asks once. Home then reads the fix without a second dialog.
/// Tests substitute [FixedDeviceLocation] so the widget suite never opens the
/// platform dialog.
/// @author Kosply-mobile
library;

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// @title DeviceFix
/// @notice One GPS reading and the place name that belongs to it.
class DeviceFix {
  /// @notice Creates a fix.
  /// @param latitude WGS84 latitude.
  /// @param longitude WGS84 longitude.
  /// @param label Short place name.
  /// @return A new {DeviceFix} instance.
  const DeviceFix({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  /// @dev WGS84 latitude.
  final double latitude;

  /// @dev WGS84 longitude.
  final double longitude;

  /// @dev Short place name.
  final String label;

  /// @notice False for a missing pin. A stored `0,0` is the unset default.
  bool get hasPin => latitude.abs() > 0.000001 || longitude.abs() > 0.000001;
}

/// @title DeviceLocation
/// @notice Reads one position, or null when it cannot.
abstract class DeviceLocation {
  /// @notice Creates a location source.
  const DeviceLocation();

  /// @notice The current position and its place name.
  /// @return The fix, or null when permission or the radio failed.
  Future<DeviceFix?> currentFix();

  /// @notice Asks for location permission at most once in this process.
  /// @dev The splash calls this before Home reads a fix, so a denial is not
  /// prompted again on the shell.
  /// @return Future completing when the student has answered, or immediately
  /// when this source has no platform dialog.
  Future<void> ensurePermission() async {}

  /// @notice The place to show in the shell pill.
  /// @return A short label, or null when permission or the fix failed.
  Future<String?> currentLabel() async {
    final DeviceFix? fix = await currentFix();
    final String text = fix?.label.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}

/// @notice Joins a suburb and a city into the pill caption.
/// @param area Neighbourhood, when the geocoder has one.
/// @param city Town or city.
/// @param name Fallback place name.
/// @return The caption, or null when every part is blank.
String? captionFromParts({String? area, String? city, String? name}) {
  final String suburb = area?.trim() ?? '';
  final String town = city?.trim() ?? '';
  if (suburb.isNotEmpty && town.isNotEmpty && suburb != town) {
    return '$suburb, $town';
  }
  if (suburb.isNotEmpty) {
    return suburb;
  }
  if (town.isNotEmpty) {
    return town;
  }
  final String place = name?.trim() ?? '';
  return place.isEmpty ? null : place;
}

/// @title PlatformDeviceLocation
/// @notice GPS plus the platform geocoder.
class PlatformDeviceLocation extends DeviceLocation {
  /// @notice Creates the platform source.
  PlatformDeviceLocation();

  bool _asked = false;

  /// @notice The current permission, requesting it the first time it is still
  /// denied. A later call does not open the dialog again.
  /// @return The permission, or null when the plugin failed.
  Future<LocationPermission?> _permission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && !_asked) {
        _asked = true;
        permission = await Geolocator.requestPermission();
      }
      return permission;
    } catch (_) {
      _asked = true;
      return null;
    }
  }

  /// @notice Shows the location dialog when the student has not answered yet.
  /// @return Future completing when the dialog is done.
  @override
  Future<void> ensurePermission() async {
    await _permission();
  }

  /// @notice Reads one fix. The label falls back to "Lokasimu" when the
  /// geocoder has no name. Does not open a second permission dialog after
  /// [ensurePermission].
  /// @return The fix, or null when the student said no or the radio failed.
  @override
  Future<DeviceFix?> currentFix() async {
    try {
      final LocationPermission? permission = await _permission();
      if (permission == null ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final List<Placemark> marks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final String label = marks.isEmpty
          ? 'Lokasimu'
          : captionFromParts(
                  area: marks.first.subLocality,
                  city: marks.first.locality,
                  name: marks.first.name,
                ) ??
                'Lokasimu';
      return DeviceFix(
        latitude: position.latitude,
        longitude: position.longitude,
        label: label,
      );
    } catch (_) {
      return null;
    }
  }
}

/// @title FixedDeviceLocation
/// @notice Location source that returns one canned label.
class FixedDeviceLocation extends DeviceLocation {
  /// @notice Creates a source that resolves to [label].
  /// @param label Place name. Null stands for a denial.
  /// @param latitude Optional pin. Omitted means the label has no coordinates.
  /// @param longitude Optional pin.
  const FixedDeviceLocation(this.label, {this.latitude, this.longitude});

  /// @dev Label returned by [currentLabel]. Null stands for a denial.
  final String? label;

  /// @dev Optional latitude. Null means there is no pin.
  final double? latitude;

  /// @dev Optional longitude. Null means there is no pin.
  final double? longitude;

  /// @notice Returns [label] and the optional pin without touching the platform.
  /// @return The canned fix, or null when [label] is null or blank.
  @override
  Future<DeviceFix?> currentFix() async {
    final String text = label?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    return DeviceFix(
      latitude: latitude ?? 0,
      longitude: longitude ?? 0,
      label: text,
    );
  }
}
