# Takluk Mobile (RuangKuliah Hub)

Aplikasi Flutter untuk platform EdTech Takluk. Seluruh data katalog, progres
belajar, arsip soal, pembayaran, dan layanan Panam Hub sekarang diambil dari
Backend API Takluk (Hono + Drizzle + PostgreSQL).

## 1. Mengatur URL Backend (satu tempat)

Alamat backend **hanya** diatur di:

```
lib/core/config/app_config.dart
```

Semua endpoint di `lib/core/network/api_endpoints.dart` bersifat relatif
terhadap base URL tersebut, jadi tidak ada endpoint yang perlu diganti satu per
satu.

### Mode development (backend lokal)

| Target | Base URL otomatis |
| --- | --- |
| Android Emulator | `http://10.0.2.2:3000` |
| iOS Simulator / Desktop / Web | `http://localhost:3000` |

Untuk perangkat Android fisik, gunakan IP LAN komputer, misalnya:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
```

### Setelah backend di-deploy online

Cukup jalankan aplikasi dengan:

```bash
flutter run --dart-define=API_BASE_URL=https://api.takluk.id
```

Atau ubah nilai `defaultBaseUrl` di `lib/core/config/app_config.dart`
menjadi URL production. Tidak ada perubahan kode lain yang diperlukan.

## 2. Menjalankan Aplikasi

```bash
flutter pub get
flutter run
```

Backend default berjalan di `http://localhost:3000`
(Swagger: `http://localhost:3000/docs`).

## 3. Akun Demo

Seed backend menyediakan akun:

- Email: `aisyah@takluk.dev`
- OTP development: `123456`

Tombol **Masuk dengan Akun Demo** di halaman auth memakai akun tersebut.
`X-Device-ID` dibuat otomatis dari perangkat dan dikirim pada setiap request
(Single Device Binding).

## 4. Endpoint yang Terhubung

| Fitur | Endpoint |
| --- | --- |
| Auth | `POST /api/auth/request-otp`, `POST /api/auth/verify-otp` |
| Profil | `GET/PATCH /api/profile/me`, `GET /api/profile/device`, `POST /api/profile/device/reset`, `GET /api/profile/referral` |
| Katalog | `GET /api/courses`, `GET /api/courses/videos`, `GET /api/courses/videos/:id` |
| Video | `GET /api/courses/videos/:id/play` (Signed HLS) |
| Progres | `POST /api/progress/sync`, `GET /api/progress/resume`, `GET /api/progress/bookmarks` |
| Arsip Soal | `GET /api/archives`, `POST /api/archives/:id/evaluate` |
| Pembayaran | `POST /api/payments/qris`, `GET /api/payments/history`, `GET /api/payments/:invoice/status`, `POST /api/payments/webhook` |
| Panam Hub | `GET /api/hub/services`, `POST /api/hub/book` |

Catatan:
- Voucher (`PANAM10`, `UINSUSKA`) divalidasi sepenuhnya oleh backend saat
  invoice QRIS dibuat.
- Tombol **Simulasi Bayar Lunas** memanggil webhook dengan
  `signature_key=mock_signature_test`, yang hanya diterima backend ketika
  `NODE_ENV=development`.
- Harga langganan mengikuti backend: **Rp25.000/bulan**.

## 5. Struktur Singkat

```
lib/
├── core/
│   ├── config/app_config.dart        # URL backend & konfigurasi global
│   ├── network/                      # Dio client, ApiClient, ApiException, endpoint
│   ├── domain/models/                # Model respons API
│   └── ...
└── features/
    ├── auth/                         # OTP & sesi JWT
    ├── home/                         # Beranda + progres
    ├── explore/                      # Pencarian video
    ├── archive/                      # Bank soal & kuis
    ├── player/                       # Pemutar & heartbeat progres
    ├── payment/                      # QRIS, polling, riwayat
    ├── profile/                      # Profil, perangkat, referral
    ├── bookmark/                     # Materi tersimpan
    └── hub/                          # Panam Academy Hub
```

## 6. Pengujian

```bash
flutter analyze
flutter test
```

`test/api_models_test.dart` memverifikasi pemetaan model terhadap bentuk
respons backend yang sebenarnya (campuran `camelCase` dan `snake_case`).

