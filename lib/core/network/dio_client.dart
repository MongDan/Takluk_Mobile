import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: AppConstants.apiTimeout,
    receiveTimeout: AppConstants.apiTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(AuthInterceptor(ref));
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => print('DIO: $obj'),
  ));

  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.read(key: 'jwt_token');
    final deviceId = await storage.read(key: 'device_id');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (deviceId != null) {
      options.headers['X-Device-ID'] = deviceId;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 403) {
      final errorCode = err.response?.data?['error_code'];
      if (errorCode == 'DEVICE_MISMATCH') {
        // Auto-logout: clear credentials
        final storage = _ref.read(secureStorageProvider);
        await storage.deleteAll();
        // The auth state listener in the app will handle navigation
      }
    }
    handler.next(err);
  }
}

/// Standard API response wrapper
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromData) {
    return ApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromData != null ? fromData(json['data']) : null,
      errorCode: json['error_code'] as String?,
    );
  }
}
