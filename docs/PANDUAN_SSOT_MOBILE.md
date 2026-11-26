# Panduan Integrasi SSOT untuk Aplikasi Mobile (Native)

**Untuk:** Developer aplikasi mobile (Android/iOS/Flutter/React Native)
**Dari:** Tim SDM-BE (SSOT) · **Base URL:** `https://be-sdm.uin-suska.ac.id`

Dokumen ini menjelaskan cara aplikasi mobile login lewat SSOT dan memakai
otorisasinya. **Berbeda dari web** (yang berbasis redirect OAuth), mobile memakai
**Native Google Sign-In** → tukar `id_token` ke SSOT → terima JWT langsung (JSON).

---

## 1. Perbedaan alur web vs mobile

| | Web | **Mobile (dokumen ini)** |
|---|---|---|
| Login | Redirect ke `/login?callback=` → Google → `/google_callback` → redirect balik | **Native Google Sign-In** di device → kirim `id_token` ke API |
| Hasil | Redirect `app_url/auth/callback?token=...` | **JSON** berisi `access_token` + `user` |
| Masa token akses | ~5 hari | **~30 hari** (lebih panjang) |
| Butuh `app_url`/callback? | Ya | **Tidak** |

## 2. Prasyarat
1. **Aplikasi terdaftar di SSOT** → punya `app_id` (mis. `SDM-MOBILE-APP`). Minta ke tim SDM.
2. **Konfigurasi Google Sign-In** memakai **Google Cloud Project yang sama** dengan SSOT:
   - Mobile mendapatkan **ID token** dari Google Sign-In SDK.
   - `serverClientId` / audience = **WEB_CLIENT_ID milik SSOT** (minta ke tim SDM) agar
     `id_token` dapat diverifikasi backend SSOT.
   - Client ID Android/iOS didaftarkan di project Google SSOT (koordinasi dgn tim SDM).
3. Pengguna harus **pegawai terdaftar & aktif di SDM** dengan **minimal 1 role**
   (kalau tidak: login ditolak — lihat §6).

## 3. Alur login (native)
```
[User] tap "Login dengan Google"
   → Google Sign-In SDK (device) → dapat id_token (audience = WEB_CLIENT_ID SSOT)
   → POST /authKJNPFj4389h3gniujs/google/mobile { id_token, platform, app_id }
   → SSOT verifikasi id_token ke Google → cek pegawai aktif + punya role
   → balas JSON { access_token, refresh_token, user }
   → simpan token aman (Keystore/Keychain) → pakai Bearer di request berikutnya
```

### 3.1 Endpoint login
```
POST https://be-sdm.uin-suska.ac.id/authKJNPFj4389h3gniujs/google/mobile
Content-Type: application/json
```
**Body:**
```json
{
  "id_token": "<Google ID token dari Sign-In SDK>",
  "platform": "android",          // opsional: "android" | "ios"
  "app_id":   "SDM-MOBILE-APP"     // opsional, default "SDM-APP"
}
```
**(Opsional) Header `X-Device-ID`**: UUID device (untuk manajemen sesi per-perangkat).

**Sukses (HTTP 200):**
```json
{
  "status": 1, "rc": 200, "message": "Login successful",
  "data": {
    "access_token": "<JWT>",
    "refresh_token": "<JWT>",
    "token_type": "Bearer",
    "expires_in": 2592000,
    "user": {
      "id_sdm": "0198...e297", "email": "user@uin-suska.ac.id",
      "nama_sdm": "...", "nip": "...", "nidn": "...",
      "unit_id": "91", "jenis_sdm": "Dosen",
      "status_aktif": "aktif", "status_pegawai": "PNS",
      "picture": "...", "given_name": "...", "family_name": "..."
    }
  }
}
```
> `access_token` berlaku ~30 hari. Simpan di **Android Keystore / iOS Keychain** —
> jangan di SharedPreferences/UserDefaults polos.

## 4. Memakai token
Semua request selanjutnya pakai header **`Authorization: Bearer <access_token>`**.

### 4.1 Validasi token (opsional, saat perlu memastikan masih aktif)
```
GET /v1/auth/validate-token
Header: Authorization: Bearer <access_token>
→ 200 { status:1, valid:true, id_sdm, email, unit_id, roles[], permissions[], ... }
→ 401 bila kedaluwarsa/dicabut (force-logout) → arahkan user login ulang.
```
⚠️ **Jangan verifikasi JWT lokal di app** — JWT SSOT HS256 tanpa JWKS. Untuk cek
keabsahan, pakai endpoint ini (sekaligus deteksi pencabutan).

### 4.2 Izin user (untuk gating menu/aksi)
```
GET /permission/user/permissions?app_id=<app_id kalian>
Header: Authorization: Bearer <access_token>
→ { data: { permissions: ["read-sdm","...","..."] } }   // array string
```

### 4.3 Profil lengkap (nama/NIP/unit)
```
GET /permission/user/profile
Header: Authorization: Bearer <access_token>
→ data: { nama, nip, unit_name, unit_code, email, id_sdm, roles[], permissions[] }
```

## 5. Refresh & logout
- **Refresh** (perpanjang tanpa login ulang):
  ```
  POST /v1/auth/refresh-token     (body: { "refresh_token": "<...>" })
  ```
- **Logout** (cabut token — penting saat user keluar / ganti akun):
  ```
  POST /v1/auth/logout
  Header: Authorization: Bearer <access_token>
  ```
- **Session per-device**: kirim `X-Device-ID` konsisten agar SSOT bisa membedakan &
  mencabut sesi per-perangkat.

## 6. Penanganan error login
| Kondisi | HTTP | Aksi di app |
|---|---|---|
| `id_token` kosong/invalid/expired | 400/401 | ulangi Google Sign-In |
| Email tidak terverifikasi Google | 400 | minta user pakai akun institusi yang benar |
| Pegawai tidak terdaftar di SDM | 404 | tampilkan "akun belum terdaftar di SDM" |
| Pegawai **tidak aktif** | 403 | "akun non-aktif" |
| Pegawai **tanpa role** | 403 | "belum diberi hak akses" — hubungi admin |
| Token kedaluwarsa/dicabut (saat pakai) | 401 | refresh; kalau gagal → login ulang |

## 7. Keamanan
- Simpan token di **Keystore/Keychain**; jangan log token.
- Selalu **HTTPS**.
- Tangani **401** global: coba refresh sekali, gagal → login ulang.
- `id_token` Google hanya sekali pakai untuk tukar — jangan simpan.
- Untuk data pengguna: patuhi UU PDP; jangan cache data pribadi lebih dari perlu.

## 8. Yang perlu dari tim SDM
1. **`app_id`** untuk aplikasi mobile kalian.
2. **WEB_CLIENT_ID SSOT** (audience id_token) + koordinasi pendaftaran client
   Android/iOS di project Google SSOT.
3. (bila perlu) izin/role spesifik aplikasi kalian → kami seed di katalog SSOT.

## 9. Catatan
- Endpoint bisnis SDM lain (mis. `/internal/v1/...`) tetap butuh RBAC/JWT sesuai
  masing-masing — token dari login ini dipakai sebagai Bearer.
- Alur ini **untuk aplikasi user-facing** (manusia login). Untuk integrasi
  **backend-to-backend** (service), pakai X-App-Token (lihat panduan RPG/Storage) —
  bukan alur mobile ini.
