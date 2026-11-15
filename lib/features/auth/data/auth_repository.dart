import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/models/auth_session_model.dart';
import '../../../core/domain/models/user_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/json_utils.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

class AuthRepository {
  final ApiClient _api;

  AuthRepository(this._api);

  /// `POST /api/auth/request-otp` — kirim OTP 6 digit ke email.
  Future<void> requestOtp(String email) async {
    await _api.post(
      ApiEndpoints.requestOtp,
      data: {'email': email.trim()},
    );
  }

  /// `POST /api/auth/verify-otp` — verifikasi OTP, daftar/update profil,
  /// bind device, lalu terbitkan JWT.
  Future<AuthSession> verifyOtp({
    required String email,
    required String otpCode,
    required String deviceId,
    String? fullName,
    String? nim,
    String? university,
    int? semester,
  }) async {
    final payload = <String, dynamic>{
      'email': email.trim(),
      'otp_code': otpCode,
      'device_id': deviceId,
      if (fullName != null && fullName.trim().isNotEmpty)
        'full_name': fullName.trim(),
      if (nim != null && nim.trim().isNotEmpty) 'nim': nim.trim(),
      if (university != null && university.isNotEmpty) 'university': university,
      if (semester != null) 'semester': semester,
    };

    final data = asJsonMap(
      await _api.post(ApiEndpoints.verifyOtp, data: payload),
    );
    final userJson = asJsonMap(pick(data, ['user']));

    return AuthSession(
      token: pickString(data, ['token']),
      user: UserModel.fromJson(userJson),
      isNewUser: pickBool(userJson, ['is_new_user', 'isNewUser']),
    );
  }

  /// `GET /api/profile/me` — profil lengkap + status langganan.
  Future<UserModel> fetchProfile() async {
    final data = await _api.get(ApiEndpoints.profileMe);
    return UserModel.fromJson(asJsonMap(data));
  }

  /// `PATCH /api/profile/me` — update WhatsApp, semester, program studi.
  Future<UserModel> updateProfile({
    String? phoneNumber,
    int? semester,
    String? major,
  }) async {
    final data = await _api.patch(
      ApiEndpoints.profileMe,
      data: {
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phone_number': phoneNumber,
        if (semester != null) 'semester': semester,
        if (major != null && major.isNotEmpty) 'major': major,
      },
    );
    return UserModel.fromJson(asJsonMap(data));
  }
}


