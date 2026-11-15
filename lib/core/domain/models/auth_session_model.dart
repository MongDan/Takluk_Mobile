import 'user_model.dart';

/// Hasil `POST /api/auth/verify-otp`: JWT + data user.
class AuthSession {
  final String token;
  final UserModel user;
  final bool isNewUser;

  const AuthSession({
    required this.token,
    required this.user,
    this.isNewUser = false,
  });
}
