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

  /// URL utama backend (production). Untuk pengembangan lokal, ganti ke
  /// `http://localhost:3000` atau pakai `--dart-define=API_BASE_URL=...`.
  static const String defaultBaseUrl =
      'https://taklukbe-production.up.railway.app';

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
    // jadi otomatis memakai 10.0.2.2 — TETAPI hanya selama URL default masih
    // backend lokal. Setelah backend online (URL bukan localhost/127.0.0.1),
    // URL default langsung dipakai di semua platform tanpa pengecualian.
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _isLocalHost(defaultBaseUrl)) {
      return 'http://10.0.2.2:3000';
    }
    return _normalize(defaultBaseUrl);
  }

  /// Deteksi apakah URL menunjuk ke backend lokal (host ini).
  static bool _isLocalHost(String url) {
    final host = Uri.tryParse(url)?.host ?? '';
    return host == 'localhost' || host == '127.0.0.1';
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

  // Akun demo tidak lagi disediakan di UI; semua akun adalah akun real
  // yang terdaftar via OTP email.

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
