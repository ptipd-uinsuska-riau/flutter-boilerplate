# Suska Flutter Starter

Kerangka aplikasi mobile Flutter untuk UIN Sultan Syarif Kasim Riau (PTIPD),
diturunkan dari aplikasi Presensia. Isinya fondasi yang sudah teruji di
produksi — tanpa fitur bisnis apa pun — supaya aplikasi baru tidak mulai
dari nol.

## Yang sudah ada

- **Login Google → SSOT** (`be-sdm`): token di Keystore/Keychain, refresh
  otomatis saat 401, logout mencabut token.
- **Design system**: `AppColors` / `AppSpace` / `AppRadius` dan kit
  komponen `P*` (`lib/app/ui/suska_ui.dart`).
- **Kerangka navigasi**: `go_router` dengan 4 tab + tombol aksi utama +
  drawer; aturan redirect login terpusat dan teruji.
- **`ApiClient`** (dio): Bearer token, pembongkar envelope
  `{status:1, data}`, pesan galat yang aman ditampilkan.
- **Fitur contoh** (`lib/features/sample/`): daftar + formulir dengan pola
  `data → cubit → view`, cache-first, dan test lengkap.
- **Setelan Ukuran Teks** (aksesibilitas, maks 1,3), **cek versi/pembaruan
  wajib**, halaman Syarat & Ketentuan + Kebijakan Privasi (naskah masih
  kerangka).
- **Disiplin test**: 183 test, termasuk smoke test responsif yang memompa
  SETIAP layar di 3 ukuran + skala font 1,3 (overflow = gagal).
- **3 flavor** (`development`, `staging`, `production`), lint
  `very_good_analysis` + `bloc_lint`.

Hanya Android dan iOS. Platform lain bisa ditambah dengan
`flutter create --platforms=web .`.

## Memulai aplikasi baru

1. Di GitHub: **Use this template** → buat repo baru → clone.
2. Ganti identitas (nama paket Dart, applicationId, bundle id, nama tampil):

   ```sh
   dart run tool/rename.dart --name ppid_mobile --app-id id.ac.uinsuska.ppid --title "PPID UIN Suska"
   ```

3. Pasang dependensi dan pastikan semuanya hijau:

   ```sh
   flutter pub get
   ```

   ```sh
   flutter analyze
   ```

   ```sh
   flutter test
   ```

4. Jalankan:

   ```sh
   flutter run --flavor development -t lib/main_development.dart
   ```

Aplikasi akan terbuka sampai layar login. **Login baru berfungsi setelah
langkah "Sesudah ganti nama" di bawah selesai.**

## Sesudah ganti nama (wajib, diisi tangan)

Cari kata `GANTI` di proyek. Daftarnya:

| Apa | Di mana |
|---|---|
| Base URL backend aplikasi | `AppConfig.apiUrl` (`lib/core/config/app_config.dart`) |
| `app_id` katalog SSOT | `AppConfig.appId` — minta tim SDM-BE mendaftarkannya |
| Keterangan di bawah nama aplikasi | `AppConfig.appTagline` |
| OAuth client Android (package + SHA-1) | Google Cloud Console — [`docs/google-sign-in-setup.md`](docs/google-sign-in-setup.md) |
| OAuth client iOS | `ios/Runner/Info.plist` (`GIDClientID` + URL scheme) |
| Naskah Syarat & Ketentuan dan Kebijakan Privasi | `lib/features/legal/view/` |
| Ikon aplikasi + layar pembuka | `sh tool/branding/apply_icons.sh <logo.png>` (macOS) |
| Warna brand | nilai di `AppColors` (`lib/app/theme.dart`) |
| Izin perangkat (kamera, lokasi, …) | `AndroidManifest.xml` + `Info.plist` — tambahkan hanya saat fiturnya ada |

Cek versi aktif bila backend menyediakan `GET /app/check-version`
(kontraknya di `lib/features/app_version/data/app_version_api.dart`).
Selama endpoint itu belum ada, cek versi gagal diam-diam dan aplikasi
tetap jalan.

## Menambah fitur

Satu fitur = satu folder `lib/features/<fitur>/` berisi `data/` (API +
model) → `cubit/` → `view/`. Salin `lib/features/sample/` sebagai titik
mulai, lalu:

1. Model: `fromJson` SELALU defensif (lihat `SampleItem.fromJson`).
2. API: terima `ApiClient`, bongkar respons dengan `unwrapEnvelope`
   (contoh di komentar `SampleApi`).
3. Daftarkan API di `lib/app/view/app.dart` (`RepositoryProvider`) dan
   rutenya di `lib/app/router.dart`.
4. Tulis test dulu, baru implementasi.
5. **Daftarkan halaman baru di `test/features/responsive_smoke_test.dart`.**

Aturan lengkap (design system, testing, jebakan yang sudah pernah
dialami) ada di [`CLAUDE.md`](CLAUDE.md) — berlaku untuk manusia maupun
asisten AI.

## Build rilis

```sh
flutter build appbundle --release --flavor production -t lib/main_production.dart --dart-define=FLAVOR=production --obfuscate --split-debug-info=symbols/VERSI
```

Simpan folder `symbols/VERSI` per rilis — tanpa itu stack trace build
ter-obfuscate tidak bisa dibaca. Keystore rilis dibaca dari
`android/key.properties` (git-ignored) atau variabel lingkungan
`ANDROID_KEYSTORE_*`.

`AppConfig.appVersion` + `AppConfig.appBuild` wajib sama dengan
`version:` di `pubspec.yaml` (dijaga `test/core/app_version_sync_test.dart`).
