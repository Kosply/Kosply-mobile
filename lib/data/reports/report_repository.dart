/// @title Report repository
/// @notice Files a buyer report through `POST /api/reports`.
/// @dev Review stays on the admin API. The phone only submits.
/// @author Kosply-mobile
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/json_read.dart';
import '../../providers/network/api_provider.dart';

/// @title ReportRepository
/// @notice Report intake.
class ReportRepository {
  /// @notice Creates the repository.
  /// @param api Backend client.
  /// @return A new {ReportRepository} instance.
  ReportRepository({required this.api});

  /// @dev Backend client.
  final ApiClient api;

  /// @notice Files a report. At least one target is required.
  /// @param reportedProductId Product id, when reporting a listing.
  /// @param reportedUserId User id, when reporting a student.
  /// @param category One of the backend categories, default `LAINNYA`.
  /// @param description What happened.
  /// @return The server report number, when present.
  Future<String> file({
    String? reportedProductId,
    String? reportedUserId,
    String category = 'LAINNYA',
    required String description,
  }) async {
    final Map<String, dynamic> json = await api.post(
      '/api/reports',
      body: <String, Object?>{
        if (reportedProductId != null && reportedProductId.isNotEmpty)
          'reportedProductId': reportedProductId,
        if (reportedUserId != null && reportedUserId.isNotEmpty)
          'reportedUserId': reportedUserId,
        'category': category,
        'description': description,
      },
    );
    final Map<String, dynamic> item =
        json.object('item') ?? const <String, dynamic>{};
    final String number = item.str('reportNo');
    return number.isEmpty ? item.str('id') : number;
  }
}

/// @dev Report intake.
final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(api: ref.watch(apiClientProvider)),
);
