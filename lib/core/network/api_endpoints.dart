class ApiEndpoints {
  // Auth
  static const String requestOtp = '/api/auth/request-otp';
  static const String verifyOtp = '/api/auth/verify-otp';

  // Courses
  static const String courses = '/api/courses';
  static String courseVideos(String courseId) => '/api/courses/$courseId/videos';
  static String videoPlay(String videoId) => '/api/courses/videos/$videoId/play';

  // Progress
  static const String progressSync = '/api/progress/sync';
  static const String bookmarks = '/api/progress/bookmarks';

  // Archives
  static const String archives = '/api/archives';
  static String archiveQuestions(String courseId) => '/api/archives/$courseId/questions';

  // Payments
  static const String createQris = '/api/payments/qris';
  static String checkPayment(String txId) => '/api/payments/$txId/status';
  static const String validateVoucher = '/api/payments/voucher/validate';
  static const String transactions = '/api/payments/transactions';

  // Profile
  static const String profile = '/api/profile';
  static const String deviceInfo = '/api/profile/device';
  static const String resetDevice = '/api/profile/device/reset';
}
