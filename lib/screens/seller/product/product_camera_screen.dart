/// @title ProductCameraScreen
/// @notice Captures the listing photos before the add-product form opens.
/// @author Kosply-mobile
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/camera/listing_camera.dart';
import '../../../core/camera/providers/camera_provider.dart';
import '../../../models/catalog/listing_photos.dart';
import '../../../providers/catalog/listing_photos_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';

/// @title ProductCameraScreen
/// @notice Live camera on top, captured photo slots below. Opened from the
/// add-product form; Lanjut returns there once every slot is filled.
/// @dev Photos only come from fresh shots, never the gallery.
class ProductCameraScreen extends ConsumerStatefulWidget {
  /// @notice Creates the product camera screen.
  /// @return A new {ProductCameraScreen} instance.
  const ProductCameraScreen({super.key});

  /// @dev Named route for this screen.
  static const routeName = '/product-camera';

  /// @notice Pushes this screen onto the current route stack.
  /// @param context The build context.
  /// @return Future completing when the screen is popped.
  static Future<void> push(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  /// @notice Creates the camera state.
  /// @return The {_ProductCameraScreenState} instance.
  @override
  ConsumerState<ProductCameraScreen> createState() =>
      _ProductCameraScreenState();
}

/// @dev Viewfinder lifecycle.
enum _CameraStatus { off, ready, failed }

/// @title _ProductCameraScreenState
/// @notice Owns the camera and keeps it closed while the app is in the
/// background or the add-product form is on top.
class _ProductCameraScreenState extends ConsumerState<ProductCameraScreen>
    with WidgetsBindingObserver {
  late final ListingCamera _camera;
  _CameraStatus _status = _CameraStatus.off;
  ListingCameraFailure _failure = ListingCameraFailure.unavailable;
  bool _flashOn = false;
  bool _busy = false;
  bool _pausedByLifecycle = false;

  @override
  void initState() {
    super.initState();
    _camera = ref.read(listingCameraFactoryProvider)();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_open());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_camera.close());
    super.dispose();
  }

  /// @notice Releases the camera in the background and restarts it on return.
  /// @dev Only reacts while the preview is live, so the permission dialog
  /// that briefly makes the app inactive during the first open is ignored.
  /// @param state The new app lifecycle state.
  /// @return void
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive && _status == _CameraStatus.ready) {
      _pausedByLifecycle = true;
      _close();
    } else if (state == AppLifecycleState.resumed && _pausedByLifecycle) {
      _pausedByLifecycle = false;
      unawaited(_open());
    }
  }

  Future<void> _open() async {
    try {
      await _camera.open();
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _CameraStatus.ready;
        _flashOn = false;
      });
    } on ListingCameraException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _CameraStatus.failed;
        _failure = error.failure;
      });
    }
  }

  void _close() {
    setState(() => _status = _CameraStatus.off);
    unawaited(_camera.close());
  }

  void _retry() {
    setState(() => _status = _CameraStatus.off);
    unawaited(_open());
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _capture() async {
    setState(() => _busy = true);
    try {
      final String path = await _camera.capture();
      if (mounted) {
        ref.read(listingPhotosProvider.notifier).add(path);
      }
    } on ListingCameraException {
      if (mounted) {
        _toast('Gagal mengambil foto, coba lagi.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _switchLens() async {
    setState(() => _busy = true);
    try {
      await _camera.switchLens();
      if (mounted) {
        setState(() => _flashOn = false);
      }
    } on ListingCameraException catch (error) {
      if (mounted) {
        setState(() {
          _status = _CameraStatus.failed;
          _failure = error.failure;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _toggleFlash() async {
    final bool next = !_flashOn;
    try {
      await _camera.setFlash(next);
      if (mounted) {
        setState(() => _flashOn = next);
      }
    } on ListingCameraException {
      if (mounted) {
        _toast('Flash tidak tersedia di kamera ini.');
      }
    }
  }

  /// @notice Returns to the add-product form with the camera released.
  /// @dev The form stays underneath and reads the captured paths.
  /// @return void
  void _next() {
    _close();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  /// @notice Builds the split camera and photo strip.
  /// @param context The build context.
  /// @return The screen widget.
  @override
  Widget build(BuildContext context) {
    final ListingPhotos photos = ref.watch(listingPhotosProvider);
    final Color onShell = KosplyColors.textPrimaryOf(context);
    final bool canShoot =
        _status == _CameraStatus.ready && !_busy && !photos.isComplete;

    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          key: const Key('product-camera-back'),
          icon: PhosphorGlyph(PhosphorCode.arrowLeft, size: 20, color: onShell),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Foto ${photos.count}/${ListingPhotos.required}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: onShell,
          ),
        ),
        actions: [
          TextButton(
            key: const Key('product-camera-next'),
            onPressed: photos.isComplete ? _next : null,
            style: TextButton.styleFrom(
              foregroundColor: KosplyColors.primary,
              disabledForegroundColor: KosplyColors.textSecondaryOf(context),
            ),
            child: const Text(
              'Lanjut',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildViewfinder(canShoot)),
          _buildStrip(photos),
        ],
      ),
    );
  }

  Widget _buildViewfinder(bool canShoot) {
    final bool ready = _status == _CameraStatus.ready;

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: switch (_status) {
              _CameraStatus.ready => _camera.buildPreview(),
              _CameraStatus.failed => _CameraMessage(
                failure: _failure,
                onRetry: _retry,
              ),
              _CameraStatus.off => const SizedBox.shrink(),
            },
          ),
          if (ready)
            Positioned(
              top: 12,
              left: 12,
              child: _RoundButton(
                key: const Key('product-camera-flash'),
                codePoint: _flashOn
                    ? PhosphorCode.lightning
                    : PhosphorCode.lightningSlash,
                onPressed: _toggleFlash,
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: _ShutterButton(
                key: const Key('product-camera-shutter'),
                onPressed: canShoot ? _capture : null,
              ),
            ),
          ),
          if (ready && _camera.canSwitchLens)
            Positioned(
              right: 24,
              bottom: 34,
              child: _RoundButton(
                key: const Key('product-camera-flip'),
                codePoint: PhosphorCode.cameraRotate,
                onPressed: _busy ? null : _switchLens,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStrip(ListingPhotos photos) {
    return Material(
      color: KosplyColors.surfaceOf(context),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              for (int i = 0; i < ListingPhotos.required; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _PhotoSlot(
                      key: Key('product-camera-slot-$i'),
                      index: i,
                      path: photos.slots[i],
                      isNext: photos.nextSlot == i,
                      onRemove: () =>
                          ref.read(listingPhotosProvider.notifier).remove(i),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// @title _CameraMessage
/// @notice Explains why the viewfinder is empty.
class _CameraMessage extends StatelessWidget {
  const _CameraMessage({required this.failure, required this.onRetry});

  final ListingCameraFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final String message = switch (failure) {
      ListingCameraFailure.denied =>
        'Izin kamera ditolak.\nAktifkan izin kamera untuk Kosply di '
            'pengaturan HP.',
      ListingCameraFailure.unavailable =>
        'Kamera tidak tersedia di perangkat ini.',
    };

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PhosphorGlyph(
            PhosphorCode.camera,
            size: 40,
            color: Colors.white70,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const Key('product-camera-retry'),
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}

/// @title _ShutterButton
/// @notice White ring shutter, dimmed while disabled.
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color tone = Colors.white.withValues(
      alpha: onPressed == null ? 0.4 : 1,
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: 'Ambil foto',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: tone, width: 4),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: tone),
          ),
        ),
      ),
    );
  }
}

/// @title _RoundButton
/// @notice Translucent round icon button floating over the viewfinder.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.codePoint,
    required this.onPressed,
    super.key,
  });

  final int codePoint;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: PhosphorGlyph(codePoint, size: 22, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// @title _PhotoSlot
/// @notice One square in the photo strip: a captured thumbnail with a remove
/// badge, or a numbered placeholder highlighted when it is next.
class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.index,
    required this.path,
    required this.isNext,
    required this.onRemove,
    super.key,
  });

  final int index;
  final String? path;
  final bool isNext;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String? photo = path;
    final BorderRadius radius = BorderRadius.circular(10);

    if (photo == null) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isNext ? KosplyColors.primary.withValues(alpha: 0.08) : null,
          borderRadius: radius,
          border: Border.all(
            color: isNext
                ? KosplyColors.primary
                : KosplyColors.outlineOf(context),
            width: isNext ? 2 : 1,
          ),
        ),
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isNext
                ? KosplyColors.primary
                : KosplyColors.textSecondaryOf(context),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: radius,
          child: Image.file(
            File(photo),
            fit: BoxFit.cover,
            cacheWidth: 192,
            errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stack,
            ) => ColoredBox(color: KosplyColors.outlineOf(context)),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            key: Key('product-camera-remove-$index'),
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                child: const Center(
                  child: PhosphorGlyph(
                    PhosphorCode.x,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
