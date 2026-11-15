import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/domain/models/profile_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/json_utils.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

class ProfileRepository {
  final ApiClient _api;

  ProfileRepository(this._api);

  /// `GET /api/profile/device` — perangkat yang sedang terikat.
  Future<DeviceBindingModel> getDeviceInfo() async {
    final data = await _api.get(ApiEndpoints.profileDevice);
    return DeviceBindingModel.fromJson(asJsonMap(data));
  }

  /// `POST /api/profile/device/reset` tanpa `otp_code` — minta OTP konfirmasi.
  Future<DeviceBindingModel> requestDeviceResetOtp({
    required String newDeviceId,
  }) async {
    final data = await _api.post(
      ApiEndpoints.profileDeviceReset,
      data: {'new_device_id': newDeviceId},
    );
    return DeviceBindingModel.fromJson(asJsonMap(data));
  }

  /// `POST /api/profile/device/reset` dengan `otp_code` — pindahkan sesi.
  Future<DeviceBindingModel> confirmDeviceReset({
    required String newDeviceId,
    required String otpCode,
  }) async {
    final data = await _api.post(
      ApiEndpoints.profileDeviceReset,
      data: {
        'new_device_id': newDeviceId,
        'otp_code': otpCode,
      },
    );
    return DeviceBindingModel.fromJson(asJsonMap(data));
  }

  /// `GET /api/profile/referral` — kode & statistik referral.
  Future<ReferralModel> getReferralInfo() async {
    final data = await _api.get(ApiEndpoints.profileReferral);
    return ReferralModel.fromJson(asJsonMap(data));
  }
}
