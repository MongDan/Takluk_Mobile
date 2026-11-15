import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Dio client tunggal untuk seluruh aplikasi.
///
/// `baseUrl` diambil dari [AppConfig.apiBaseUrl] sehingga pergantian alamat
/// backend cukup dilakukan di satu tempat.
final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      sendTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(ref));

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('DIO: $obj'),
      ),
    );
  }

  return dio;
});

/// Menyisipkan `Authorization: Bearer <JWT>` dan `X-Device-ID` pada setiap
/// request yang membutuhkannya (Single Device Binding).
class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.read(key: StorageKeys.jwtToken);
    final deviceId = await storage.read(key: StorageKeys.deviceId);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (deviceId != null && deviceId.isNotEmpty) {
      options.headers['X-Device-ID'] = deviceId;
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    final errorCode = data is Map ? data['error_code']?.toString() : null;

    // Akun dipakai di perangkat lain / dinonaktifkan: bersihkan sesi lokal.
    if (status == 403 &&
        (errorCode == 'DEVICE_MISMATCH' || errorCode == 'ACCOUNT_DISABLED')) {
      final storage = _ref.read(secureStorageProvider);
      await storage.delete(key: StorageKeys.jwtToken);
      await storage.delete(key: StorageKeys.userJson);
    }

    handler.next(err);
  }
}

