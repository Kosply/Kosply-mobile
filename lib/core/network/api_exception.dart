/// @title ApiException
/// @notice Every failed backend call, normalised to one type.
/// @dev The server answers errors as `{status: error, code, message, details}`
/// with codes from `lib/server/middlewares/errorCatalog.js`. Transport failures
/// (no route to the host, timeout) become code [ApiException.network] with
/// status 0, so screens branch on [code] and never on exception classes.
/// @author Kosply-mobile
library;

/// @title ApiException
/// @notice A backend error code plus a sentence a student can read.
class ApiException implements Exception {
  /// @notice Creates the exception.
  /// @param statusCode HTTP status, 0 when no response arrived.
  /// @param code Backend error code, e.g. `INVALID_CREDENTIALS`.
  /// @param message Server message, kept for logs.
  /// @param details Optional validation details from the server.
  /// @return A new {ApiException} instance.
  const ApiException({
    required this.statusCode,
    required this.code,
    this.message = '',
    this.details,
  });

  /// @dev Code used when the request never reached the server.
  static const String network = 'NETWORK';

  /// @dev HTTP status, 0 when no response arrived.
  final int statusCode;

  /// @dev Backend error code.
  final String code;

  /// @dev Server message, kept for logs.
  final String message;

  /// @dev Optional validation details: a string or a list of strings.
  final Object? details;

  /// @notice Whether the session is no longer accepted.
  bool get isUnauthorized => statusCode == 401;

  /// @notice Whether the device could not reach the server at all.
  bool get isNetwork => code == network;

  /// @notice Indonesian sentence for a snackbar or a field error.
  /// @return The user-facing message.
  String get userMessage {
    switch (code) {
      case network:
        return 'Tidak bisa terhubung ke server. Cek koneksi kamu.';
      case 'INVALID_CREDENTIALS':
        return 'Email atau password salah.';
      case 'EMAIL_TAKEN':
        return 'Email ini sudah terdaftar.';
      case 'USERNAME_TAKEN':
        return 'Username ini sudah dipakai.';
      case 'RESET_INVALID':
      case 'EMAIL_CODE_INVALID':
        return 'Kode salah atau sudah kedaluwarsa.';
      case 'EMAIL_NOT_SENT':
        return 'Email verifikasi belum terkirim. Coba lagi.';
      case 'RATE_LIMITED':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
      case 'SELLER_NOT_APPROVED':
        return 'Akun kamu belum terverifikasi sebagai penjual.';
      case 'FORBIDDEN':
        return 'Kamu tidak punya akses untuk aksi ini.';
      case 'AGENT_UNAVAILABLE':
      case 'AGENT_ERROR':
        return 'AI sedang tidak tersedia. Coba lagi sebentar lagi.';
      case 'SOCIAL_DISABLED':
        return 'Login sosial belum diaktifkan di server.';
      case 'SOCIAL_AUTH_FAILED':
        return 'Login sosial gagal. Coba lagi.';
      case 'GOOGLE_NOT_CONFIGURED':
        return 'Login Google belum dikonfigurasi di aplikasi ini.';
      case 'APPLE_NOT_CONFIGURED':
        return 'Login Apple belum dikonfigurasi di aplikasi ini.';
      case 'VERIFICATION_EXISTS':
        return 'Pengajuan verifikasi kamu masih diproses.';
      case 'NEEDS_APPROVAL':
        return 'AI butuh persetujuanmu sebelum melanjutkan.';
      case 'TOKEN_INVALID':
      case 'TOKEN_REVOKED':
      case 'UNAUTHORIZED':
        return 'Sesi kamu berakhir. Silakan masuk lagi.';
      case 'ACCOUNT_DISABLED':
        return 'Akun ini dinonaktifkan.';
      case 'PAYLOAD_TOO_LARGE':
        return 'Foto terlalu besar.';
      case 'UNSUPPORTED_MEDIA_TYPE':
        return 'Format foto tidak didukung.';
      case 'PRODUCT_NOT_FOUND':
        return 'Barang ini sudah tidak tersedia.';
      case 'TICKET_CLOSED':
        return 'Tiket ini sudah ditutup.';
      case 'VALIDATION':
        return 'Data yang dikirim belum valid.';
      default:
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }

  @override
  String toString() => 'ApiException($statusCode $code: $message)';
}
