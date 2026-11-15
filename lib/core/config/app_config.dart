import 'package:flutter/foundation.dart';

/// Satu-satunya tempat untuk mengatur alamat Backend Takluk.
///
/// Cara mengganti URL backend saat sudah deploy online:
///   1. Ubah [defaultBaseUrl] menjadi URL production, ATAU
///   2. Jalankan aplikasi dengan `--dart-define=API_BASE_URL=https://api.takluk.id`
///      (cara ini tidak perlu mengubah kode sama sekali).
///
/// Semua endpoint di `ApiEndpoints` bersifat relatif terhadap URL ini, jadi
/// tidak ada lagi endpoint yang perlu diganti satu per satu.
class AppConfig {
  AppConfig._();

  /// URL utama backend. Ganti nilai ini setelah backend di-deploy online,
  /// atau gunakan `--dart-define=API_BASE_URL=https://domain-backend`.
  static const String defaultBaseUrl = 'http://localhost:3000';

  /// Override dari `--dart-define=API_BASE_URL=...` (prioritas tertinggi).
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String? _runtimeOverride;

  /// Base URL aktif yang dipakai seluruh request API.
  static String get apiBaseUrl {
    if (_runtimeOverride != null && _runtimeOverride!.isNotEmpty) {
      return _normalize(_runtimeOverride!);
    }
    if (_envBaseUrl.isNotEmpty) {
      return _normalize(_envBaseUrl);
    }
    // Emulator Android tidak bisa mengakses `localhost` komputer host,
    // gunakan 10.0.2.2. Untuk perangkat fisik gunakan --dart-define.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return _normalize(defaultBaseUrl);
  }

  /// Mengubah base URL saat aplikasi berjalan (mis. dari halaman pengaturan).
  static void setApiBaseUrl(String url) {
    _runtimeOverride = _normalize(url);
  }

  /// Mengembalikan base URL ke nilai default.
  static void resetApiBaseUrl() {
    _runtimeOverride = null;
  }

  static String _normalize(String url) {
    final trimmed = url.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  // Networking
  static const Duration apiTimeout = Duration(seconds: 30);

  // Pricing (harus sama dengan backend: Rp25.000/bulan)
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

  // Akun demo (seed backend: aisyah@takluk.dev, OTP 123456 di mode development)
  static const String demoEmail = 'aisyah@takluk.dev';
  static const String demoOtp = '123456';

  // Jadwal ujian untuk widget hitung mundur (konfigurasi produk, bukan data API).
  static DateTime get nextExamDate {
    final now = DateTime.now();
    final month = now.month;
    if (month >= 1 && month <= 3) return DateTime(now.year, 3, 15);
    if (month >= 4 && month <= 6) return DateTime(now.year, 6, 10);
    if (month >= 7 && month <= 9) return DateTime(now.year, 10, 15);
    return DateTime(now.year + 1, 1, 10);
  }

  static String get nextExamLabel {
    final month = DateTime.now().month;
    if (month >= 1 && month <= 3) return 'UTS Genap';
    if (month >= 4 && month <= 6) return 'UAS Genap';
    if (month >= 7 && month <= 9) return 'UTS Ganjil';
    return 'UAS Ganjil';
  }
}
