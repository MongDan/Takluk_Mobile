import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/domain/models/user_model.dart';
import '../../../../core/domain/mock_data.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/security/device_info_service.dart';
import '../../data/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool otpSent;
  final bool otpVerifying;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.otpSent = false,
    this.otpVerifying = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? otpSent,
    bool? otpVerifying,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      otpSent: otpSent ?? this.otpSent,
      otpVerifying: otpVerifying ?? this.otpVerifying,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
    ref.read(deviceInfoServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final FlutterSecureStorage _storage;
  final DeviceInfoService _deviceInfo;

  AuthNotifier(this._repository, this._storage, this._deviceInfo)
      : super(const AuthState());

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: MockData.demoUser,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> requestOtp(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final success = await _repository.requestOtp(email);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        otpSent: success,
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Gagal mengirim OTP. Coba lagi.',
      );
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String email,
    required String otpCode,
    String? fullName,
    String? nim,
    String? university,
    int? semester,
  }) async {
    state = state.copyWith(otpVerifying: true);
    try {
      final deviceId = await _deviceInfo.getDeviceId();
      final user = await _repository.verifyOtp(
        email: email,
        otpCode: otpCode,
        deviceId: deviceId,
        fullName: fullName,
        nim: nim,
        university: university,
        semester: semester,
      );

      if (user != null) {
        await _storage.write(key: 'jwt_token', value: 'demo_jwt_${user.id}');
        await _storage.write(key: 'device_id', value: deviceId);

        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
        MockData.demoUser = user;
        return true;
      } else {
        state = state.copyWith(
          otpVerifying: false,
          errorMessage: 'Kode OTP salah. Periksa kembali.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        otpVerifying: false,
        errorMessage: 'Verifikasi gagal. Coba lagi.',
      );
      return false;
    }
  }

  Future<void> loginAsDemo() async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 400));

    final deviceId = await _deviceInfo.getDeviceId();
    await _storage.write(key: 'jwt_token', value: 'demo_jwt_usr-demo-001');
    await _storage.write(key: 'device_id', value: deviceId);

    MockData.demoUser = MockData.demoUser.copyWith(activeDeviceId: deviceId);
    state = AuthState(
      status: AuthStatus.authenticated,
      user: MockData.demoUser,
    );
  }

  void updateSubscription(DateTime validUntil) {
    if (state.user != null) {
      final updated = state.user!.copyWith(subscriptionValidUntil: validUntil);
      MockData.demoUser = updated;
      state = state.copyWith(user: updated);
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void resetDemoData() {
    MockData.demoUser = MockData.demoUser.copyWith(
      subscriptionValidUntil: DateTime.now().add(const Duration(days: 25)),
    );
    MockData.watchHistories.clear();
    state = state.copyWith(user: MockData.demoUser);
  }
}

