# Panduan Proyek

Aplikasi ini dibangun dari **Suska Flutter Starter** (kerangka turunan
aplikasi Presensia, PTIPD UIN Sultan Syarif Kasim Riau). Aturan di bawah
adalah pelajaran dari Presensia di produksi — ikuti kecuali ada alasan
tertulis untuk menyimpang.

## Perintah penting

```sh
flutter analyze          # wajib: No issues found!
flutter test             # wajib: semua hijau

flutter run --flavor development -t lib/main_development.dart

# Ganti identitas aplikasi (paket Dart, applicationId, bundle id, nama):
dart run tool/rename.dart --name <paket> --app-id <id> --title "<Nama>"
```

Flavor: `development` | `staging` | `production` (entrypoint
`lib/main_<flavor>.dart`).

## Arsitektur

- **Satu fitur = `data/` (API + model) → `cubit/` → `view/`** di
  `lib/features/<fitur>/`. Acuan hidup: `lib/features/sample/`.
- Model `fromJson` SELALU defensif (fallback per field, tanpa `as` yang
  bisa melempar): server tidak boleh bisa membuat aplikasi crash.
- Backend membungkus respons dalam envelope `{status:1, data:...}` —
  bongkar via `unwrapEnvelope` (`core/api/api_envelope.dart`). Galat:
  `{status:0, code, message}`; tampilkan lewat `apiErrorMessage`.
- `ApiClient` (dio) menyisipkan Bearer token + refresh-401 via SSOT.
- `MemoryCache` (`core/cache`) untuk cache-first antarlayar; dibersihkan
  saat logout dan di setiap test (`test/flutter_test_config.dart`).
- Router `go_router` `StatefulShellRoute.indexedStack` 4 cabang; rute lain
  di level atas. Aturan login ada di SATU fungsi murni `redirectFor`.
- Layar di kerangka tab hidup terus dan TIDAK dibangun ulang saat halaman
  di atasnya ditutup — bila data berubah di halaman lain, beri tahu
  cubit-nya (lihat `SampleApi.changes`).
- `TextScaleCubit` (`core/settings`) = setelan Ukuran Teks; diterapkan di
  builder MaterialApp (dikali skala sistem), maks 1.3.

## Aturan design system (WAJIB)

1. Warna hanya dari `AppColors` (`lib/app/theme.dart`) — tak ada
   `Color(0x…)` di file layar.
2. Kartu hanya `PCard` / `cardDecoration()` — jangan membuat
   `BoxDecoration` kartu sendiri.
3. Padding layar `AppSpace.screen`, antar blok `AppSpace.stack`; radius
   hanya `AppRadius.card/field/chip`.
4. Komponen reusable di `lib/app/ui/suska_ui.dart` (PCard, PRequestCard,
   PStatusBadge, PFilterChips, PField/PDateField/PDropdownField/
   PUploadField, PMetric, PMiniStat, PEmptyState, PRow…). Galerinya ada di
   tab Komponen.
5. **Jangan ubah label teks tanpa sadar** — widget test mencari teks eksak.
6. Halaman baru WAJIB didaftarkan di
   `test/features/responsive_smoke_test.dart` (3 ukuran layar + skala font
   1.3; overflow = merah). Angka besar bungkus `FittedBox(scaleDown)`;
   jangan beri tinggi mati pada kartu berisi teks.
7. Data yang belum disediakan backend ditampilkan `-` / keadaan menunggu —
   JANGAN mengarang angka.
8. Jangan menaruh `ListTile` di dalam kartu berlatar (`PCard`) — efek
   tekannya hilang dan Flutter melempar assertion; pakai `InkWell` + `Row`.

## Testing

- TDD: test dulu (RED) baru implementasi (GREEN). Sebelum klaim selesai:
  `flutter analyze` bersih + `flutter test` hijau, baru commit.
- Mocktail: stub `any(named: 'x')` TIDAK cocok bila pemanggil tak mengirim
  named arg — tulis argumen eksplisit di kode produksi walau sama dengan
  default.
- Font test (Ahem) jauh lebih LEBAR dari Inter — layout yang lolos test
  pasti lega di perangkat nyata.
- Halaman tinggi: perbesar viewport test
  (`tester.view.physicalSize = Size(800, 1600)`) agar sliver membangun
  semua anak; `scrollUntilVisible` + `ensureVisible` sebelum `tap`.
- Spinner: pakai `pump`, bukan `pumpAndSettle` (hang).
- `DateFormat(..., 'id_ID')` butuh `initializeDateFormatting` — di app
  sudah dipanggil (`app.dart`); di test inisialisasi sendiri.

## Konfigurasi & kredensial

- Nilai bertanda `GANTI` (`AppConfig`, `Info.plist`) wajib diisi per
  aplikasi — daftarnya di README.
- **applicationId SEMUA flavor sama** (OAuth Android client terikat
  package + SHA-1). Jangan menambah suffix `.dev/.stg` dan jangan membuat
  client GCP baru tanpa keputusan pemilik aplikasi.
- `google_sign_in` DIKUNCI di v6. v7/Credential Manager menyamarkan client
  tak terdaftar sebagai "[16] Account reauth failed" — jangan upgrade.
- Web Client ID di `auth_repository.dart` milik SSOT dan sama untuk semua
  aplikasi kampus — jangan diganti.
- Keystore (`*.keystore`, `*.jks`), `android/key.properties`, dan
  `google-services.json` git-ignored. Jangan pernah meng-commit-nya.
- `AppConfig.appVersion` + `AppConfig.appBuild` WAJIB sinkron dengan
  `version: x.y.z+N` di pubspec (dijaga
  `test/core/app_version_sync_test.dart`).

## Catatan backend

- SSOT be-sdm (`AppConfig.ssotUrl`): auth, profil, permission. Kontrak di
  `docs/PANDUAN_SSOT_MOBILE.md`; penyiapan Google Sign-In di
  `docs/google-sign-in-setup.md`.
- Permission dicek via DAFTAR `GET /permission/user/permissions`
  (`SsotApi.getUserPermissions`) + `contains` — endpoint
  `check-permission` terbukti salah jawab di Presensia.
- Token iOS ber-`aud` client iOS (beda dengan Android) — SSOT harus
  mengenal client iOS aplikasi ini.
