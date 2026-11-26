import 'package:suska_starter/features/app_version/data/app_version_api.dart';

/// Putuskan apakah layar update perlu ditampilkan — `null` = tidak.
///
/// Kontrak (asal: be-presensia): `update_available` dihitung backend
/// dari `version` saja (mis. `1.1.0` vs `1.1.0`). Versi sama tetapi build
/// lebih lama dideteksi di sini; batas build wajib datang lewat `min_build`.
///
/// 1. Data versi kosong (`latest_version ""` / `latest_build 0`, mis. iOS
///    yang belum ada di toko) → tidak ada update.
/// 2. [installedBuild] < `min_build` → update WAJIB, apa pun kata backend
///    soal `is_required` (backend menghitung hal yang sama dari query
///    `build`; aturan ini menjaga bila nilainya tak terbaca di sana).
/// 3. `update_available` → ikuti backend (wajib bila `is_required`).
/// 4. Versi sama dan [installedBuild] < `latest_build` → update OPSIONAL,
///    kecuali backend menyatakan `is_required`.
/// 5. Selain itu (termasuk build terpasang LEBIH BARU — build uji) → tidak.
///
/// `latest_build` tak dikirim (kontrak lama) → aturan 4 tak berlaku;
/// `min_build` kosong/0 → aturan 2 tak berlaku.
VersionCheck? decideUpdate(
  VersionCheck check, {
  required String installedVersion,
  required int installedBuild,
}) {
  final latestBuild = check.latestBuild;
  if (check.latestVersion.isEmpty || latestBuild == 0) return null;

  final minBuild = check.minBuild;
  if (minBuild != null && minBuild > 0 && installedBuild < minBuild) {
    return check.copyWith(updateAvailable: true, isRequired: true);
  }
  if (check.updateAvailable) return check;

  final sameVersion = installedVersion == check.latestVersion;
  if (sameVersion && latestBuild != null && installedBuild < latestBuild) {
    return check.copyWith(updateAvailable: true);
  }
  return null;
}
