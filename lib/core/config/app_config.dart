import 'package:flutter/foundation.dart';

/// Konfigurasi aplikasi. SEMUA nilai bertanda `GANTI` wajib diisi ulang
/// untuk aplikasi turunan (lihat README, bagian "Sesudah ganti nama").
abstract final class AppConfig {
  /// Flavor aktif: `development` | `staging` | `production`.
  static const flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'development');

  static bool get isProduction => flavor == 'production';

  /// GANTI — nama yang tampil di layar pembuka, login, dan halaman legal.
  /// (`tool/rename.dart --title` mengisinya.)
  static const appName = 'Suska Starter';

  /// GANTI — keterangan singkat di bawah nama aplikasi.
  static const appTagline =
      'Kerangka aplikasi\nUIN Sultan Syarif Kasim Riau';

  /// GANTI — base URL backend aplikasi ini (yang membungkus respons dalam
  /// envelope `{status:1, data}`). Bisa ditimpa per build:
  /// `--dart-define=API_URL=https://...`.
  ///
  /// Nilai bawaan sengaja memakai domain `.invalid` supaya aplikasi yang
  /// lupa diisi GAGAL terhubung, bukan diam-diam memanggil server lain.
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.ganti-saya.invalid/api/v1',
  );

  /// Base URL SSOT (be-sdm): autentikasi, profil, dan permission. Sama
  /// untuk semua aplikasi kampus — lihat `docs/PANDUAN_SSOT_MOBILE.md`.
  static const ssotUrl = 'https://be-sdm.uin-suska.ac.id';

  static const apiTimeout = Duration(seconds: 10);
  static const ssotTimeout = Duration(seconds: 30);

  /// GANTI — ID aplikasi di katalog SSOT. Minta tim SDM-BE mendaftarkannya;
  /// app_id yang tidak terdaftar TETAP bisa login, tetapi
  /// `/permission/user/permissions` mengembalikan daftar KOSONG.
  static const appId = 'GANTI-APP-ID';

  /// Versi aplikasi untuk cek pembaruan.
  /// PENTING: jaga sinkron dengan `version:` di pubspec.yaml (dijaga
  /// `test/core/app_version_sync_test.dart`).
  static const appVersion = '0.1.0';

  /// Kode versi (bagian `+N` di pubspec = `versionCode` Android /
  /// `CFBundleVersion` iOS). Konstanta, bukan dibaca dari platform: APK
  /// `--split-per-abi` mengubah versionCode sehingga tak sebanding dengan
  /// `latest_build` backend.
  static const appBuild = 1;

  /// GANTI — halaman toko yang dibuka layar "Perbarui Aplikasi" bila
  /// backend tidak mengirim `download_url`. KOSONG = tombol hanya menutup.
  /// (`tool/rename.dart --app-id` mengisinya dengan tautan Play Store.)
  static const storeUrl = '';

  static void debugPrintConfig() {
    if (kDebugMode) {
      debugPrint('[AppConfig] flavor=$flavor api=$apiUrl ssot=$ssotUrl');
    }
  }
}
