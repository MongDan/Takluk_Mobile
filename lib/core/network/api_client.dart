import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_exception.dart';
import 'dio_client.dart';
import 'json_utils.dart';

/// Pembungkus tipis Dio yang otomatis membuka envelope respons backend:
/// `{ success, message, data }` -> `data`.
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return _request(() => _dio.get<dynamic>(path, queryParameters: _clean(query)));
  }

  Future<dynamic> post(String path, {Object? data}) async {
    return _request(() => _dio.post<dynamic>(path, data: data));
  }

  Future<dynamic> patch(String path, {Object? data}) async {
    return _request(() => _dio.patch<dynamic>(path, data: data));
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      return _unwrap(response);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  dynamic _unwrap(Response<dynamic> response) {
    final body = response.data;
    if (body is Map) {
      final json = asJsonMap(body);
      if (json['success'] == false) {
        throw ApiException(
          code: pickString(json, ['error_code'], fallback: 'API_ERROR'),
          message: pickString(
            json,
            ['message'],
            fallback: 'Terjadi kesalahan pada server Takluk.',
          ),
          statusCode: response.statusCode,
        );
      }
      return json['data'];
    }
    return body;
  }

  /// Membuang query parameter bernilai null/kosong agar tidak ditolak validator.
  Map<String, dynamic>? _clean(Map<String, dynamic>? query) {
    if (query == null) return null;
    final cleaned = <String, dynamic>{};
    query.forEach((key, value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      cleaned[key] = value;
    });
    return cleaned.isEmpty ? null : cleaned;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioClientProvider));
});
