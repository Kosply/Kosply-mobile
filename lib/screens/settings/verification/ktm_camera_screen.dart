/// @title KTM camera
/// @notice Captures one photo and returns its file path.
/// @dev Uses the same {ListingCamera} as listing photos, so tests can swap it.
/// Built for the student card; the profile editor reuses it with its own
/// [KtmCameraScreen.title].
/// @author Kosply-mobile
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/camera/listing_camera.dart';
import '../../../core/camera/providers/camera_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';

/// @title KtmCameraScreen
/// @notice One-shot camera for the KTM upload and the profile photo.
class KtmCameraScreen extends ConsumerStatefulWidget {
  /// @notice Creates the camera.
  /// @param title App bar title naming what is being photographed.
  /// @return A new {KtmCameraScreen} instance.
  const KtmCameraScreen({this.title = ktmTitle, super.key});

  /// @dev Default title, for the student card.
  static const String ktmTitle = 'Foto KTM';

  /// @dev App bar title naming what is being photographed.
  final String title;

  /// @notice Pushes the camera and returns the captured path.
  /// @param context The build context.
  /// @param title App bar title naming what is being photographed.
  /// @return The file path, or null when the student backs out.
  static Future<String?> push(BuildContext context, {String title = ktmTitle}) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        settings: const RouteSettings(name: '/ktm-camera'),
        builder: (_) => KtmCameraScreen(title: title),
      ),
    );
  }

  @override
  ConsumerState<KtmCameraScreen> createState() => _KtmCameraScreenState();
}

class _KtmCameraScreenState extends ConsumerState<KtmCameraScreen> {
  late final ListingCamera _camera;
  bool _ready = false;
  bool _busy = false;
  String? _shot;

  @override
  void initState() {
    super.initState();
    _camera = ref.read(listingCameraFactoryProvider)();
    _open();
  }

  Future<void> _open() async {
    try {
      await _camera.open();
      if (mounted) {
        setState(() => _ready = true);
      }
    } on ListingCameraException {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _camera.close();
    super.dispose();
  }

  Future<void> _shoot() async {
    if (!_ready || _busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final String path = await _camera.capture();
      if (!mounted) {
        return;
      }
      if (widget.title != KtmCameraScreen.ktmTitle) {
        Navigator.of(context).pop(path);
        return;
      }
      setState(() {
        _shot = path;
        _busy = false;
      });
    } on ListingCameraException {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? shot = _shot;
    if (shot != null) {
      return _KtmPreview(
        path: shot,
        onRetake: () => setState(() => _shot = null),
        onUse: () => Navigator.of(context).pop(shot),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(child: _ready ? _camera.buildPreview() : const SizedBox()),
      floatingActionButton: FloatingActionButton(
        key: const Key('ktm-shutter'),
        backgroundColor: KosplyColors.primary,
        onPressed: _shoot,
        child: const PhosphorGlyph(PhosphorCode.camera, color: Colors.white),
      ),
    );
  }
}

/// @title _KtmPreview
/// @notice The captured student card, shown flat, before it is kept.
class _KtmPreview extends StatelessWidget {
  const _KtmPreview({
    required this.path,
    required this.onRetake,
    required this.onUse,
  });

  final String path;
  final VoidCallback onRetake;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KosplyColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: KosplyColors.backgroundOf(context),
        elevation: 0,
        title: const Text('Pratinjau KTM'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  key: const Key('ktm-camera-preview'),
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1.586,
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stack,
                      ) => const ColoredBox(color: Color(0xFFE7E5E4)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('ktm-retake'),
                    onPressed: onRetake,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KosplyColors.textPrimaryOf(context),
                      side: BorderSide(color: KosplyColors.outlineOf(context)),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Foto ulang',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    key: const Key('ktm-use'),
                    onPressed: onUse,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: KosplyColors.primary,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Pakai foto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
