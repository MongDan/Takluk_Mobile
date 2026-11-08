import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/enums.dart';
import '../../../core/domain/models/user_model.dart';
import '../../../core/domain/mock_data.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  Future<bool> requestOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<UserModel?> verifyOtp({
    required String email,
    required String otpCode,
    required String deviceId,
    String? fullName,
    String? nim,
    String? university,
    int? semester,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (otpCode != AppConstants.demoOtp) {
      return null;
    }

    if (email == AppConstants.demoEmail) {
      return MockData.demoUser.copyWith(activeDeviceId: deviceId);
    }

    return UserModel(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName ?? 'Mahasiswa Baru',
      nim: nim ?? '12250312345',
      university: university != null ? University.fromValue(university) : University.UIN_SUSKA,
      semester: semester ?? 1,
      activeDeviceId: deviceId,
      referralCode: 'REF${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      createdAt: DateTime.now(),
    );
  }
}

