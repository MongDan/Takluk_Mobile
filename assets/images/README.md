# Gambar Aset

Letakkan gambar logo untuk splash screen di folder ini dengan nama:

```
splash_logo.png
```

Path tersebut sudah dipakai di `AppConstants.splashLogoAsset` dan
`lib/features/auth/presentation/screens/splash_screen.dart`.

- Format disarankan: PNG transparan, rasio 1:1, minimal 512 x 512 px.
- Gambar ditampilkan dengan `BoxFit.contain` di area 84 x 84, jadi seluruh
  bagian gambar tetap terlihat.
- Selama file belum ada, splash otomatis memakai logo bawaan (fallback)
  sehingga aplikasi tetap berjalan normal.
