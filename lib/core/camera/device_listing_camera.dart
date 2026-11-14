/// @title DeviceListingCamera
/// @notice {ListingCamera} backed by the `camera` plugin.
/// @author Kosply-mobile
library;

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import 'listing_camera.dart';

/// @title DeviceListingCamera
/// @notice Drives the phone camera for listing photos.
/// @dev Operations run one after another so a close triggered by the app
/// lifecycle can never overlap the next open on the same lens.
class DeviceListingCamera implements ListingCamera {
  /// @dev Plugin error codes meaning access was refused or restricted.
  static const Set<String> _deniedCodes = <String>{
    'CameraAccessDenied',
    'CameraAccessDeniedWithoutPrompt',
    'CameraAccessRestricted',
  };

  List<CameraDescription> _lenses = const <CameraDescription>[];
  int _lens = 0;
  CameraController? _controller;
  Future<void> _pending = Future<void>.value();

  @override
  bool get canSwitchLens =>
      _lenses
          .map((CameraDescription lens) => lens.lensDirection)
          .toSet()
          .length >
      1;

  @override
  Future<void> open() => _run(_start);

  @override
  Future<void> close() => _run(_release);

  @override
  Future<void> switchLens() => _run(() async {
    final CameraLensDirection current = _lenses[_lens].lensDirection;
    final int other = _lenses.indexWhere(
      (CameraDescription lens) => lens.lensDirection != current,
    );
    if (other < 0) {
      return;
    }
    _lens = other;
    await _start();
  });

  @override
  Future<void> setFlash(bool on) => _run(() async {
    await _ready().setFlashMode(on ? FlashMode.always : FlashMode.off);
  });

  @override
  Future<String> capture() => _run(() async {
    final XFile file = await _ready().takePicture();
    return file.path;
  });

  @override
  Widget buildPreview() {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return CameraPreview(controller);
  }

  /// @notice Opens the selected lens, discovering lenses on first use.
  /// @return Future completing once the preview is live.
  Future<void> _start() async {
    await _release();
    if (_lenses.isEmpty) {
      _lenses = await availableCameras();
      final int back = _lenses.indexWhere(
        (CameraDescription lens) =>
            lens.lensDirection == CameraLensDirection.back,
      );
      _lens = back < 0 ? 0 : back;
    }
    if (_lenses.isEmpty) {
      throw const ListingCameraException(ListingCameraFailure.unavailable);
    }
    final CameraController controller = CameraController(
      _lenses[_lens],
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller = controller;
    await controller.initialize();
    // @dev The plugin defaults to auto flash; the screen starts with it off.
    try {
      await controller.setFlashMode(FlashMode.off);
    } on CameraException {
      // @dev Lenses without a flash reject this; there is nothing to turn off.
    }
  }

  /// @notice Disposes the active controller, if any.
  /// @return Future completing once the camera is released.
  Future<void> _release() async {
    final CameraController? controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  /// @notice Returns the live controller.
  /// @return The initialized {CameraController}.
  CameraController _ready() {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const ListingCameraException(ListingCameraFailure.unavailable);
    }
    return controller;
  }

  /// @notice Queues [task] behind earlier operations and maps plugin errors.
  /// @param task The camera operation.
  /// @return The task result.
  Future<T> _run<T>(Future<T> Function() task) {
    final Future<T> result = _pending.then((_) async {
      try {
        return await task();
      } on ListingCameraException {
        rethrow;
      } on CameraException catch (error) {
        throw ListingCameraException(
          _deniedCodes.contains(error.code)
              ? ListingCameraFailure.denied
              : ListingCameraFailure.unavailable,
        );
      } on Exception {
        // @dev e.g. MissingPluginException on platforms without the plugin.
        throw const ListingCameraException(ListingCameraFailure.unavailable);
      }
    });
    _pending = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }
}
