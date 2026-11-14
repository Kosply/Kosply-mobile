/// @title Camera provider
/// @notice Exposes how screens create a {ListingCamera}.
/// @dev A factory rather than an instance: the camera screen owns the camera
/// it creates and closes it on dispose. Widget tests override this with a
/// fake camera.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../device_listing_camera.dart';
import '../listing_camera.dart';

/// @dev Creates the camera used for listing photos.
final listingCameraFactoryProvider = Provider<ListingCamera Function()>(
  (ref) => DeviceListingCamera.new,
);
