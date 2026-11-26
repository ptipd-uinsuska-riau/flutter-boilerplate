# Menyiapkan Google Sign-In (SSOT) untuk aplikasi baru

Login memakai Google Sign-In native (`google_sign_in` **v6**) yang menukar
`id_token` ke backend SSOT `be-sdm` (kontraknya di
[`PANDUAN_SSOT_MOBILE.md`](PANDUAN_SSOT_MOBILE.md)). Google hanya
menerbitkan `id_token` bila aplikasi terdaftar sebagai **OAuth client** di
Google Cloud project yang SAMA dengan Web Client ID milik SSOT.

Tanpa langkah di bawah, tombol "Masuk" akan gagal — itu bukan bug kode.

## Yang sudah ada di kode (jangan diubah per aplikasi)

| Item | Nilai | Lokasi |
|---|---|---|
| Web Client ID SSOT (audience `id_token`) | `263220023664-095mcq19vsna1t6jomj5i9jm51fpd8ks.apps.googleusercontent.com` | `lib/features/auth/data/auth_repository.dart` → `_webClientId` |
| Base URL SSOT | `https://be-sdm.uin-suska.ac.id` | `AppConfig.ssotUrl` |

Web Client ID ini HARUS sama dengan `xconfig.yaml` di SDM Backend. Ia milik
SSOT dan dipakai bersama oleh semua aplikasi kampus.

## Yang harus didaftarkan untuk SETIAP aplikasi

### 1. `app_id` di katalog SSOT (tim SDM-BE)

Minta tim SDM-BE mendaftarkan aplikasi dan katalog permission-nya, lalu
isi `AppConfig.appId`. `app_id` yang tidak terdaftar TETAP bisa login,
tetapi `GET /permission/user/permissions` mengembalikan daftar kosong
sehingga gating menu tidak jalan.

### 2. OAuth client Android (Google Cloud Console)

Pendaftaran dilakukan di Google Cloud project nomor `263220023664` oleh
pemegang akses project itu — bukan di sisi backend SSOT.

1. Buka <https://console.cloud.google.com/apis/credentials>.
2. **Create Credentials → OAuth client ID → Android**.
3. Isi package name = `applicationId` aplikasi (lihat
   `android/app/build.gradle.kts`) dan SHA-1. Daftarkan SATU client per
   SHA-1:

| Keystore | Cara melihat SHA-1 | Dipakai untuk |
|---|---|---|
| Debug bersama `android/app/debug.keystore` | `keytool -list -v -keystore android/app/debug.keystore -storepass android` | semua build debug |
| Upload release | `keytool -list -v -keystore <keystore-rilis>` | build release lokal |
| Play App Signing | Play Console → App integrity → App signing | rilis lewat Play Store |

Client ID Android TIDAK perlu ditaruh di kode — cukup ada di GCP supaya
Google mempercayai aplikasi.

**Keystore debug bersama.** `build.gradle.kts` memakai
`android/app/debug.keystore` bila berkas itu ada (git-ignored; password
`android`, alias `androiddebugkey`). Buat satu, bagikan ke tim lewat jalur
aman, dan daftarkan SHA-1-nya — seluruh tim lalu bisa login di build debug.
Tanpa berkas itu tiap komputer memakai keystore debug bawaannya sendiri
dengan SHA-1 berbeda.

**Semua flavor memakai `applicationId` yang sama.** Suffix `.dev`/`.stg`
berarti mendaftarkan client baru per flavor. Konsekuensinya dev/stg/prod
tidak bisa terpasang berdampingan di satu perangkat; nama di bawah ikon
(`[DEV]`, `[STG]`) tetap membedakannya.

### 3. OAuth client iOS

1. **Create Credentials → OAuth client ID → iOS**, bundle id = bundle id
   aplikasi.
2. Isi `ios/Runner/Info.plist`:
   - `GIDClientID` = client id iOS (`xxx.apps.googleusercontent.com`);
   - URL scheme = client id yang dibalik (`com.googleusercontent.apps.xxx`).
3. **Kabari tim SDM-BE.** Token dari iOS ber-`aud` client iOS (berbeda
   dari Android, yang ber-`aud` Web Client ID), jadi SSOT harus mengenal
   client iOS itu. Saat panduan ini ditulis, slot `IOS_CLIENT_ID` di SSOT
   hanya menampung SATU nilai dan sudah dipakai aplikasi Presensia —
   aplikasi iOS kedua butuh perubahan di sisi SDM. Tanyakan lebih awal.

## Bila login gagal

| Gejala | Arti |
|---|---|
| `DEVELOPER_ERROR [10]` / "This android application is not registered to use OAuth" | package + SHA-1 build ini belum terdaftar sebagai OAuth client Android |
| `[16] Account reauth failed` | pesan menyesatkan dari `google_sign_in` v7 untuk masalah yang sama — itu sebabnya paket DIKUNCI di v6 |
| 401 dari SSOT di iOS saja | client iOS belum dikenal SSOT (lihat langkah 3) |
| 403 | akun non-aktif atau belum punya role di SDM |
| 404 | akun belum terdaftar di SDM |
| Login sukses tetapi menu kosong | `AppConfig.appId` belum terdaftar di katalog SSOT |

**Jangan upgrade `google_sign_in` ke v7** tanpa menguji login di emulator
dan perangkat fisik: v7 (Credential Manager) menyembunyikan penyebab
sebenarnya di balik `[16] Account reauth failed`.
