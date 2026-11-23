/// @title Fake listing camera
/// @notice In-memory {ListingCamera} for widget tests.
/// @dev Records every call so tests can assert when the camera opens and
/// closes. Captures return made-up paths that never resolve to a file.
/// @author Kosply-mobile
library;

import 'package:flutter/widgets.dart';
import 'package:kosply_mobile/core/camera/listing_camera.dart';

/// @title FakeListingCamera
/// @notice Camera stand-in that never touches the platform.
class FakeListingCamera implements ListingCamera {
  /// @notice Creates the fake.
  /// @param failure When set, every {open} throws with this failure.
  /// @param canSwitchLens Whether the flip button should show.
  /// @return A new {FakeListingCamera} instance.
  FakeListingCamera({this.failure, this.canSwitchLens = true});

  /// @dev Failure thrown by {open}, null to open normally.
  final ListingCameraFailure? failure;

  @override
  final bool canSwitchLens;

  /// @dev Number of {open} calls.
  int opens = 0;

  /// @dev Number of {close} calls.
  int closes = 0;

  /// @dev Number of photos taken.
  int shots = 0;

  /// @dev Number of lens flips.
  int switches = 0;

  /// @dev Last flash setting applied.
  bool flash = false;

  /// @dev Whether the preview is live.
  bool isOpen = false;

  @override
  Future<void> open() async {
    opens++;
    final ListingCameraFailure? reason = failure;
    if (reason != null) {
      throw ListingCameraException(reason);
    }
    isOpen = true;
  }

  @override
  Future<void> close() async {
    closes++;
    isOpen = false;
  }

  @override
  Future<void> switchLens() async {
    switches++;
  }

  @override
  Future<void> setFlash(bool on) async {
    flash = on;
  }

  @override
  Future<String> capture() async {
    shots++;
    return 'fake/photo-$shots.jpg';
  }

  @override
  Widget buildPreview() {
    return const ColoredBox(
      key: Key('fake-camera-preview'),
      color: Color(0xFF444444),
    );
  }
}
