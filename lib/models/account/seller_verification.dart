/// @title Seller verification
/// @notice The caller's KTM application from `GET /api/verifications/me`.
/// @author Kosply-mobile
library;

import '../../core/network/json_read.dart';

/// @title SellerVerification
/// @notice One verification application.
class SellerVerification {
  /// @notice Creates the application.
  /// @param id Row id.
  /// @param status `PENDING`, `APPROVED`, or `REJECTED`.
  /// @param namaLengkap Full name on the KTM.
  /// @param nim Student number.
  /// @param universitas Campus.
  /// @param programStudi Study programme.
  /// @param rejectionReason Why a rejection happened, empty otherwise.
  /// @return A new {SellerVerification} instance.
  const SellerVerification({
    required this.id,
    required this.status,
    required this.namaLengkap,
    required this.nim,
    required this.universitas,
    required this.programStudi,
    this.rejectionReason = '',
  });

  /// @notice Reads an application row.
  /// @param json Backend object.
  /// @return The application.
  factory SellerVerification.fromJson(Map<String, dynamic> json) {
    return SellerVerification(
      id: json.str('id'),
      status: json.str('status'),
      namaLengkap: json.str('namaLengkap'),
      nim: json.str('nim'),
      universitas: json.str('universitas'),
      programStudi: json.str('programStudi'),
      rejectionReason: json.str('rejectionReason'),
    );
  }

  /// @dev Row id.
  final String id;

  /// @dev `PENDING`, `APPROVED`, or `REJECTED`.
  final String status;

  /// @dev Full name on the KTM.
  final String namaLengkap;

  /// @dev Student number.
  final String nim;

  /// @dev Campus.
  final String universitas;

  /// @dev Study programme.
  final String programStudi;

  /// @dev Why a rejection happened.
  final String rejectionReason;

  /// @notice Whether the student can sell.
  bool get isApproved => status == 'APPROVED';

  /// @notice Whether a decision is still outstanding.
  bool get isPending => status == 'PENDING';

  /// @notice Whether review refused the application.
  bool get isRejected => status == 'REJECTED';
}
