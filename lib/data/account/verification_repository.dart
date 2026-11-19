/// @title Verification repository
/// @notice Submits and reads the caller's KTM application.
/// @dev `POST /api/verifications` and `GET /api/verifications/me`. Admin review
/// stays off the phone.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/json_read.dart';
import '../../models/account/seller_verification.dart';
import '../../providers/network/api_provider.dart';

/// @title VerificationRepository
/// @notice Seller verification calls.
class VerificationRepository {
  /// @notice Creates the repository.
  /// @param api Backend client.
  /// @return A new {VerificationRepository} instance.
  VerificationRepository({required this.api});

  /// @dev Backend client.
  final ApiClient api;

  /// @notice The caller's application, or null when they have never applied.
  /// @return The application.
  Future<SellerVerification?> mine() async {
    final Map<String, dynamic> json = await api.get('/api/verifications/me');
    final Map<String, dynamic>? item = json.object('item');
    if (item == null || item.str('id').isEmpty) {
      return null;
    }
    return SellerVerification.fromJson(item);
  }

  /// @notice Submits or resubmits the application.
  /// @param namaLengkap Full name on the KTM.
  /// @param nim Student number.
  /// @param universitas Campus.
  /// @param programStudi Study programme.
  /// @param ktmImageUrl Uploaded photo URL.
  /// @return The stored application.
  Future<SellerVerification> submit({
    required String namaLengkap,
    required String nim,
    required String universitas,
    required String programStudi,
    required String ktmImageUrl,
  }) async {
    final Map<String, dynamic> json = await api.post(
      '/api/verifications',
      body: <String, String>{
        'namaLengkap': namaLengkap,
        'nim': nim,
        'universitas': universitas,
        'programStudi': programStudi,
        'ktmImageUrl': ktmImageUrl,
      },
    );
    return SellerVerification.fromJson(
      json.object('item') ?? const <String, dynamic>{},
    );
  }
}

/// @dev Seller verification calls.
final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => VerificationRepository(api: ref.watch(apiClientProvider)),
);

/// @dev The caller's application. Invalidated after a submit or a refresh.
final sellerVerificationProvider =
    FutureProvider.autoDispose<SellerVerification?>((ref) {
      return ref.watch(verificationRepositoryProvider).mine();
    });
