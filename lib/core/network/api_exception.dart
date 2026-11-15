import 'package:dio/dio.dart';
import 'json_utils.dart';

/// Error terstandar dari backend Takluk.
///
/// Backend selalu mengirim bentuk:
/// `{ "success": false, "error_code": "...", "message": "..." }`
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isPaymentRequired => statusCode == 402;
  bool get isDeviceMismatch => code == 'DEVICE_MISMATCH';
  bool get isAccountDisabled => code == 'ACCOUNT_DISABLED';
  bool get isNotFound => statusCode == 404;
  bool get isNetworkError =>
      code == 'NETWORK_ERROR' || code == 'CONNECTION_TIMEOUT';

  /// Sesi tidak valid lagi (token kedaluwarsa / perangkat berpindah).
  bool get requiresReLogin => isUnauthorized || isDeviceMismatch;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;

    if (data is Map) {
      final json = asJsonMap(data);
      final code = pickString(json, ['error_code', 'code'], fallback: '');
      final message = pickString(json, ['message'], fallback: '');
      if (code.isNotEmpty || message.isNotEmpty) {
        return ApiException(
          code: code.isEmpty ? 'API_ERROR' : code,
          message: message.isEmpty
              ? 'Terjadi kesalahan pada server Takluk.'
              : message,
          statusCode: response?.statusCode,
        );
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          code: 'CONNECTION_TIMEOUT',
          message: 'Koneksi ke server Takluk terlalu lama. Coba lagi ya!',
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const ApiException(
          code: 'NETWORK_ERROR',
          message:
              'Tidak dapat terhubung ke server Takluk. Periksa koneksi internet kamu ya!',
        );
      case DioExceptionType.cancel:
        return const ApiException(
          code: 'REQUEST_CANCELLED',
          message: 'Permintaan dibatalkan.',
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          code: 'BAD_CERTIFICATE',
          message: 'Sertifikat server tidak valid.',
        );
      case DioExceptionType.badResponse:
        return ApiException(
          code: 'API_ERROR',
          message: 'Server Takluk mengembalikan respons yang tidak dikenali.',
          statusCode: response?.statusCode,
        );
    }
  }

  @override
  String toString() => message;
}
