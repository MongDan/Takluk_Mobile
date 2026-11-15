import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/domain/models/user_model.dart';
import '../../../../core/network/api_exception.dart';
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
    ref.watch(authRepositoryProvider),
    ref.watch(secureStorageProvider),
    ref.watch(deviceInfoServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final FlutterSecureStorage _storage;
  final DeviceInfoService _deviceInfo;

  AuthNotifier(this._repository, this._storage, this._deviceInfo)
      : super(const AuthState());

  /// Memulihkan sesi dari token JWT yang tersimpan, lalu menyegarkan profil
  /// dari `GET /api/profile/me`.
  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: StorageKeys.jwtToken);
    if (token == null || token.isEmpty) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    // Pastikan X-Device-ID tersedia untuk seluruh request terproteksi.
    await _deviceInfo.getDeviceId();

    try {
      final user = await _repository.fetchProfile();
      await _persistUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (error) {
      if (error.requiresReLogin) {
        await _clearSession();
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: error.message,
        );
        return;
      }
      // Gagal jaringan: tetap pakai profil terakhir yang tersimpan.
      final cached = await _readCachedUser();
      state = cached != null
          ? AuthState(status: AuthStatus.authenticated, user: cached)
          : AuthState(
              status: AuthStatus.unauthenticated,
              errorMessage: error.message,
            );
    } catch (_) {
      final cached = await _readCachedUser();
      state = cached != null
          ? AuthState(status: AuthStatus.authenticated, user: cached)
          : const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> requestOtp(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _repository.requestOtp(email);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        otpSent: true,
      );
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
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
    state = state.copyWith(otpVerifying: true, errorMessage: null);
    try {
      final deviceId = await _deviceInfo.getDeviceId();
      final session = await _repository.verifyOtp(
        email: email,
        otpCode: otpCode,
        deviceId: deviceId,
        fullName: fullName,
        nim: nim,
        university: university,
        semester: semester,
      );

      await _storage.write(key: StorageKeys.jwtToken, value: session.token);
      await _storage.write(key: StorageKeys.deviceId, value: deviceId);

      // Profil lengkap (referral code, masa aktif, dll) diambil dari backend.
      var user = session.user;
      try {
        user = await _repository.fetchProfile();
      } on ApiException {
        // Tetap gunakan data dari respons verify-otp bila profil gagal dimuat.
      }

      await _persistUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(
        otpVerifying: false,
        errorMessage: error.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        otpVerifying: false,
        errorMessage: 'Verifikasi gagal. Coba lagi.',
      );
      return false;
    }
  }


  /// Masuk cepat memakai akun demo yang di-seed backend:
  /// `aisyah@takluk.dev` + OTP `123456` (mode development).
  Future<bool> loginAsDemo() {
    return verifyOtp(
      email: AppConstants.demoEmail,
      otpCode: AppConstants.demoOtp,
    );
  }

  /// Menyegarkan profil dari server (mis. setelah pembayaran sukses).
  Future<void> refreshProfile() async {
    try {
      final user = await _repository.fetchProfile();
      await _persistUser(user);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );
    } on ApiException catch (error) {
      state = state.copyWith(errorMessage: error.message);
    }
  }

  Future<void> logout() async {
    await _clearSession();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _persistUser(UserModel user) async {
    await _storage.write(
      key: StorageKeys.userJson,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> _readCachedUser() async {
    try {
      final raw = await _storage.read(key: StorageKeys.userJson);
      if (raw == null || raw.isEmpty) return null;
      final json = jsonDecode(raw);
      if (json is! Map) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearSession() async {
    await _storage.delete(key: StorageKeys.jwtToken);
    await _storage.delete(key: StorageKeys.userJson);
  }
}


