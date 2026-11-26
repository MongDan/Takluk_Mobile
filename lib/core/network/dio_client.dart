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
/// `baseUrl` dibaca ulang dari [AppConfig.apiBaseUrl] pada setiap request
/// (lewat [BaseUrlInterceptor]), jadi pergantian alamat backend cukup diatur
/// di satu tempat dan langsung berlaku tanpa restart. Untuk perangkat fisik,
/// gunakan `--dart-define=API_BASE_URL=http://<IP>:3000`.
final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: AppConfig.apiTimeout,
      receiveTimeout: AppConfig.apiTimeout,
      sendTimeout: AppConfig.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Base URL dibaca ulang di SETIAP request dari AppConfig, sehingga
  // pergantian alamat backend langsung berlaku tanpa restart aplikasi.
  dio.interceptors.add(BaseUrlInterceptor());

  dio.interceptors.add(AuthInterceptor(ref));

  if (kDebugMode) {
    debugPrint('⇢ API Base URL: ${AppConfig.apiBaseUrl}');
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

/// Menempelkan `baseUrl` terbaru dari [AppConfig.apiBaseUrl] ke setiap request.
class BaseUrlInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.baseUrl = AppConfig.apiBaseUrl;
    handler.next(options);
  }
}

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

