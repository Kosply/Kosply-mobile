/// @title Listing draft provider
/// @notice Drives the add-product form: upload photos, let the AI fill the
/// card, then publish with the seller's price, quantity and meeting point.
/// @dev The AI owns title, description and category; the form shows them
/// locked. Uploaded URLs are kept, so "Coba lagi" after an AI failure does not
/// upload the same five photos twice. Auto-disposed with the form.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../data/catalog/catalog_repository.dart';
import '../../data/uploads/upload_repository.dart';
import '../../models/catalog/listing_card.dart';
import '../chat/ai_chat_provider.dart';
import '../network/api_provider.dart';
import 'catalog_providers.dart';

/// @dev Photo uploads through `/api/uploads/images`.
final uploadRepositoryProvider = Provider<UploadRepository>(
  (ref) => UploadRepository(api: ref.watch(apiClientProvider)),
);

/// @title ListingDraftStatus
/// @notice Where the add-product flow is.
enum ListingDraftStatus {
  /// @dev No photos yet; nothing to fill.
  idle,

  /// @dev Photos are going to the server.
  uploading,

  /// @dev The AI is reading the photos.
  filling,

  /// @dev The card is filled; the seller can publish.
  ready,

  /// @dev Uploading or filling failed; retry is offered.
  failed,

  /// @dev The listing is being posted.
  publishing,

  /// @dev The listing is live.
  published,
}

/// @title ListingDraft
/// @notice Immutable state of the add-product flow.
class ListingDraft {
  /// @notice Creates a draft state.
  /// @param status Current step.
  /// @param uploaded Photos uploaded so far.
  /// @param total Photos to upload.
  /// @param imageUrls Uploaded URLs, cover first.
  /// @param card The AI card once filled.
  /// @param error User-facing error of the last failure.
  /// @return A new {ListingDraft} instance.
  const ListingDraft({
    this.status = ListingDraftStatus.idle,
    this.uploaded = 0,
    this.total = 0,
    this.imageUrls = const <String>[],
    this.card,
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

  /// @dev The AI card once filled.
  final ListingCard? card;

  /// @dev User-facing error of the last failure.
  final String? error;

  /// @notice Whether the AI fields are filled and locked.
  bool get hasCard => card != null;

  /// @notice Whether a background step is running.
  bool get isBusy =>
      status == ListingDraftStatus.uploading ||
      status == ListingDraftStatus.filling ||
      status == ListingDraftStatus.publishing;

  /// @notice Copies this state with selected fields replaced.
  /// @param status New step.
  /// @param uploaded New upload count.
  /// @param total New total.
  /// @param imageUrls New URLs.
  /// @param card New card.
  /// @param error New error; pass [clearError] to remove it.
  /// @param clearError Whether to drop the current error.
  /// @return A new {ListingDraft}.
  ListingDraft copyWith({
    ListingDraftStatus? status,
    int? uploaded,
    int? total,
    List<String>? imageUrls,
    ListingCard? card,
    String? error,
    bool clearError = false,
  }) {
    return ListingDraft(
      status: status ?? this.status,
      uploaded: uploaded ?? this.uploaded,
      total: total ?? this.total,
      imageUrls: imageUrls ?? this.imageUrls,
      card: card ?? this.card,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// @title ListingDraftNotifier
/// @notice Runs upload → AI fill → publish for one listing.
class ListingDraftNotifier extends Notifier<ListingDraft> {
  @override
  ListingDraft build() => const ListingDraft();

  /// @notice Uploads [photoPaths] (skipping done ones) and asks the AI.
  /// @dev Safe to call again after a failure: it resumes where it stopped.
  /// @param photoPaths Local capture paths, cover first.
  /// @return Future completing when the card is filled or the step failed.
  Future<void> start(List<String> photoPaths) async {
    if (photoPaths.isEmpty || state.isBusy || state.hasCard) {
      return;
    }
    final List<String> urls = List<String>.of(state.imageUrls);
    state = state.copyWith(
      status: ListingDraftStatus.uploading,
      uploaded: urls.length,
      total: photoPaths.length,
      clearError: true,
    );
    try {
      final UploadRepository uploads = ref.read(uploadRepositoryProvider);
      for (int i = urls.length; i < photoPaths.length; i++) {
        urls.add(await uploads.uploadImage(photoPaths[i]));
        if (!ref.mounted) {
          return;
        }
        state = state.copyWith(uploaded: urls.length, imageUrls: List<String>.of(urls));
      }
      state = state.copyWith(status: ListingDraftStatus.filling);
      final ListingCard card = await ref
          .read(aiChatRepositoryProvider)
          .fillListing(urls);
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(status: ListingDraftStatus.ready, card: card);
    } on ApiException catch (error) {
      _fail(error.userMessage);
    } on FormatException {
      _fail('AI belum bisa membaca foto ini. Coba lagi.');
    } on Exception {
      // A missing capture must not leave the banner spinning.
      _fail('Foto belum bisa diunggah. Coba lagi.');
    }
  }

  /// @notice Posts the listing with the seller's numbers.
  /// @param price Integer rupiah.
  /// @param stock Units available.
  /// @param location Meeting point.
  /// @return True when the listing is live.
  Future<bool> publish({
    required int price,
    required int stock,
    required String location,
  }) async {
    final ListingCard? card = state.card;
    if (card == null || state.isBusy) {
      return false;
    }
    state = state.copyWith(
      status: ListingDraftStatus.publishing,
      clearError: true,
    );
    try {
      await ref.read(catalogRepositoryProvider).createListing(
        NewListing(
          title: card.title,
          description: card.description,
          category: card.category,
          price: price,
          stock: stock,
          imageUrls: card.imageUrls.isEmpty ? state.imageUrls : card.imageUrls,
          locationLabel: location,
        ),
      );
    } on ApiException catch (error) {
      if (ref.mounted) {
        state = state.copyWith(
          status: ListingDraftStatus.ready,
          error: error.userMessage,
        );
      }
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
