class AppConstants {
  // API
  static const String baseUrl = 'https://api.takluk.id';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Pricing
  static const int subscriptionPrice = 49000;
  static const int qrisTimerMinutes = 15;

  // Video
  static const int progressSyncIntervalSec = 30;
  static const int watermarkIntervalSec = 4;
  static const double completionThreshold = 0.85;

  // OTP
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;
  static const int otpMaxAttempts = 5;
  static const String demoOtp = '123456';

  // Demo Account
  static const String demoEmail = 'aisyah@demo.takluk.id';
  static const String demoName = 'Aisyah Putri';
  static const String demoNim = '12250312345';
  static const String demoUniversity = 'UIN_SUSKA';
  static const int demoSemester = 3;

  // Layout
  static const double bottomBarHeight = 112;
  static const double touchTarget = 44;

  // Vouchers
  static const Map<String, int> vouchers = {
    'PANAM10': 10000,
    'UINSUSKA': 5000,
  };
}
