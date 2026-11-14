/// @title KTM camera
/// @notice Captures one student-card photo and returns its file path.
/// @dev Uses the same {ListingCamera} as listing photos, so tests can swap it.
/// @author Kosply-mobile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/camera/listing_camera.dart';
import '../../../core/camera/providers/camera_provider.dart';
import '../../../theme/colors/kosply_colors.dart';
import '../../../widgets/common/icons/phosphor_icons.dart';

/// @title KtmCameraScreen
/// @notice One-shot camera for the verification form.
class KtmCameraScreen extends ConsumerStatefulWidget {
  /// @notice Creates the camera.
  /// @return A new {KtmCameraScreen} instance.
  const KtmCameraScreen({super.key});

  /// @notice Pushes the camera and returns the captured path.
  /// @param context The build context.
  /// @return The file path, or null when the student backs out.
  static Future<String?> push(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const KtmCameraScreen()),
    );
  }

  @override
  ConsumerState<KtmCameraScreen> createState() => _KtmCameraScreenState();
}

class _KtmCameraScreenState extends ConsumerState<KtmCameraScreen> {
  late final ListingCamera _camera;
  bool _ready = false;
  bool _busy = false;

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
      if (mounted) {
        Navigator.of(context).pop(path);
      }
    } on ListingCameraException {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Foto KTM'),
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
