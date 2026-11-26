class AppConstants {
  // API (sumber tunggal ada di AppConfig)
  static const Duration apiTimeout = Duration(seconds: 30);

  // Assets
  static const String splashLogoAsset = 'assets/images/logotakluk.jpeg';

  // Pricing (sama dengan backend: Rp25.000/bulan)
  static const int subscriptionPrice = 25000;
  static const int qrisTimerMinutes = 15;

  // Video
  static const int progressSyncIntervalSec = 30;
  static const int watermarkIntervalSec = 4;
  static const double completionThreshold = 0.85;

  // OTP
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;
  static const int otpMaxAttempts = 5;

  // Layout
  static const double bottomBarHeight = 112;
  static const double touchTarget = 44;
}

/// Key penyimpanan lokal (flutter_secure_storage).
class StorageKeys {
  StorageKeys._();

  static const String jwtToken = 'jwt_token';
  static const String deviceId = 'device_id';
  static const String userJson = 'user_json';
}
