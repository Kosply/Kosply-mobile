/// @title ListingCamera
/// @notice Camera contract used by the product photo screen.
/// @dev The screen talks to this interface instead of the `camera` plugin so
/// widget tests can swap in a fake. {DeviceListingCamera} is the real one.
/// @author Kosply-mobile
library;

import 'package:flutter/widgets.dart';

/// @title ListingCameraFailure
/// @notice Why the camera could not be used.
enum ListingCameraFailure {
  /// @dev The user refused, or the OS restricts, camera access.
  denied,

  /// @dev No usable camera, or the camera failed to start or shoot.
  unavailable,
}

/// @title ListingCameraException
/// @notice Thrown by {ListingCamera} operations that fail.
class ListingCameraException implements Exception {
  /// @notice Creates the exception.
  /// @param failure Why the operation failed.
  /// @return A new {ListingCameraException} instance.
  const ListingCameraException(this.failure);

  /// @dev Why the operation failed.
  final ListingCameraFailure failure;

  @override
  String toString() => 'ListingCameraException(${failure.name})';
}

/// @title ListingCamera
/// @notice Live viewfinder plus shutter for listing photos.
abstract interface class ListingCamera {
  /// @notice Whether a lens facing the other way exists.
  /// @dev Only meaningful after {open} has completed.
  bool get canSwitchLens;

  /// @notice Starts the back lens, or the current lens when reopening.
  /// @dev Asks for the camera permission on first use.
  /// @return Future completing once the preview is live.
  Future<void> open();

  /// @notice Releases the camera. Safe to call when already closed.
  /// @return Future completing once the camera is released.
  Future<void> close();

  /// @notice Flips between the back and front lens.
  /// @return Future completing once the new lens is live.
  Future<void> switchLens();

  /// @notice Turns the flash on or off for the next shots.
  /// @param on Whether the flash fires.
  /// @return Future completing once the mode is applied.
  Future<void> setFlash(bool on);

  /// @notice Takes a photo.
  /// @return Path of the captured image file.
  Future<String> capture();

  /// @notice Builds the live preview at the sensor aspect ratio.
  /// @return The preview widget, empty while closed.
  Widget buildPreview();
}
