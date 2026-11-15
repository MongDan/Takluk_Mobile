/// Seluruh path endpoint backend Takluk (relatif terhadap `AppConfig.apiBaseUrl`).
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String requestOtp = '/api/auth/request-otp';
  static const String verifyOtp = '/api/auth/verify-otp';

  // Profile & Device
  static const String profileMe = '/api/profile/me';
  static const String profileDevice = '/api/profile/device';
  static const String profileDeviceReset = '/api/profile/device/reset';
  static const String profileReferral = '/api/profile/referral';

  // Courses & Videos
  static const String courses = '/api/courses';
  static const String videos = '/api/courses/videos';
  static String videoDetail(String videoId) => '/api/courses/videos/$videoId';
  static String videoPlay(String videoId) => '/api/courses/videos/$videoId/play';

  // Progress
  static const String progressSync = '/api/progress/sync';
  static const String progressResume = '/api/progress/resume';
  static const String bookmarks = '/api/progress/bookmarks';

  // Archives
  static const String archives = '/api/archives';
  static String archiveEvaluate(String questionId) =>
      '/api/archives/$questionId/evaluate';

  // Payments
  static const String paymentsQris = '/api/payments/qris';
  static const String paymentsHistory = '/api/payments/history';
  static String paymentStatus(String invoiceNumber) =>
      '/api/payments/$invoiceNumber/status';
  static const String paymentsWebhook = '/api/payments/webhook';

  // Panam Academy Hub (O2O)
  static const String hubServices = '/api/hub/services';
  static const String hubBook = '/api/hub/book';
}

