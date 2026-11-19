/// @title Listing draft provider
/// @notice Drives the add-product form: upload the seller's photos, then
/// publish the fields they typed.
/// @dev The listing model on the server stays available. This flow does not
/// call it. Auto-disposed with the form.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../data/catalog/catalog_repository.dart';
import '../../data/uploads/upload_repository.dart';
import '../network/api_provider.dart';
import 'catalog_providers.dart';

/// @dev Photo uploads through `/api/uploads/images`.
final uploadRepositoryProvider = Provider<UploadRepository>(
  (ref) => UploadRepository(api: ref.watch(apiClientProvider)),
);

/// @title ListingDraftStatus
/// @notice Where the add-product publish is.
enum ListingDraftStatus {
  /// @dev Nothing is being sent.
  idle,

  /// @dev Photos are going to the server.
  uploading,

  /// @dev The last upload or post failed.
  failed,

  /// @dev The listing is being posted.
  publishing,

  /// @dev The listing is live.
  published,
}

/// @title ListingDraft
/// @notice Immutable state of one publish attempt.
class ListingDraft {
  /// @notice Creates a draft state.
  /// @param status Current step.
  /// @param uploaded Photos uploaded so far.
  /// @param total Photos to upload.
  /// @param imageUrls Uploaded URLs, cover first.
  /// @param error User-facing error of the last failure.
  /// @return A new {ListingDraft} instance.
  const ListingDraft({
    this.status = ListingDraftStatus.idle,
    this.uploaded = 0,
    this.total = 0,
    this.imageUrls = const <String>[],
    this.error,
  });

  /// @dev Current step.
  final ListingDraftStatus status;

  /// @dev Photos uploaded so far.
  final int uploaded;

  /// @dev Photos to upload.
  final int total;

  /// @dev Uploaded URLs, cover first.
  final List<String> imageUrls;

  /// @dev User-facing error of the last failure.
  final String? error;

  /// @notice Whether a background step is running.
  bool get isBusy =>
      status == ListingDraftStatus.uploading ||
      status == ListingDraftStatus.publishing;

  /// @notice Copies this state with selected fields replaced.
  /// @param status New step.
  /// @param uploaded New upload count.
  /// @param total New total.
  /// @param imageUrls New URLs.
  /// @param error New error; pass [clearError] to remove it.
  /// @param clearError Whether to drop the current error.
  /// @return A new {ListingDraft}.
  ListingDraft copyWith({
    ListingDraftStatus? status,
    int? uploaded,
    int? total,
    List<String>? imageUrls,
    String? error,
    bool clearError = false,
  }) {
    return ListingDraft(
      status: status ?? this.status,
      uploaded: uploaded ?? this.uploaded,
      total: total ?? this.total,
      imageUrls: imageUrls ?? this.imageUrls,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// @title ListingDraftNotifier
/// @notice Uploads photos and posts the seller's own listing fields.
class ListingDraftNotifier extends Notifier<ListingDraft> {
  @override
  ListingDraft build() => const ListingDraft();

  /// @notice Uploads [photoPaths], then posts the listing.
  /// @param title Item name the seller typed.
  /// @param description Description the seller typed.
  /// @param category Category the seller picked.
  /// @param price Integer rupiah.
  /// @param stock Units available.
  /// @param location Meeting point.
  /// @param photoPaths Local capture paths, cover first.
  /// @param latitude Pin for [location], when a suggestion or GPS filled it.
  /// @param longitude Pin for [location], when a suggestion or GPS filled it.
  /// @return True when the listing is live.
  Future<bool> publish({
    required String title,
    required String description,
    required String category,
    required int price,
    required int stock,
    required String location,
    required List<String> photoPaths,
    double? latitude,
    double? longitude,
  }) async {
    final String name = title.trim();
    final String about = description.trim();
    final String picked = category.trim();
    if (state.isBusy ||
        name.isEmpty ||
        about.isEmpty ||
        picked.isEmpty ||
        photoPaths.isEmpty) {
      return false;
    }
    final List<String> urls = <String>[];
    state = state.copyWith(
      status: ListingDraftStatus.uploading,
      uploaded: 0,
      total: photoPaths.length,
      imageUrls: urls,
      clearError: true,
    );
    final UploadRepository uploads = ref.read(uploadRepositoryProvider);
    try {
      for (int i = 0; i < photoPaths.length; i++) {
        urls.add(await uploads.uploadImage(photoPaths[i]));
        if (!ref.mounted) {
          return false;
        }
        state = state.copyWith(
          uploaded: urls.length,
          imageUrls: List<String>.of(urls),
        );
      }
    } on ApiException catch (error) {
      _fail(error.userMessage);
      return false;
    } on Exception {
      _fail('Foto belum bisa diunggah. Coba lagi.');
      return false;
    }
    if (!ref.mounted) {
      return false;
    }
    state = state.copyWith(status: ListingDraftStatus.publishing);
    try {
      await ref
          .read(catalogRepositoryProvider)
          .createListing(
            NewListing(
              title: name,
              description: about,
              category: picked,
              price: price,
              stock: stock,
              imageUrls: List<String>.of(urls),
              locationLabel: location,
              latitude: latitude,
              longitude: longitude,
              includeCoordinates: latitude != null && longitude != null,
            ),
          );
    } on ApiException catch (error) {
      _fail(error.userMessage);
      return false;
    }
    if (ref.mounted) {
      state = state.copyWith(status: ListingDraftStatus.published);
    }
    return true;
  }

  void _fail(String message) {
    if (!ref.mounted) {
      return;
    }
    state = state.copyWith(status: ListingDraftStatus.failed, error: message);
  }
}

/// @dev Draft of the listing being created; disposed with the form.
final listingDraftProvider =
    NotifierProvider.autoDispose<ListingDraftNotifier, ListingDraft>(
      ListingDraftNotifier.new,
    );
