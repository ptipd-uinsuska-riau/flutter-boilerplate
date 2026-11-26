import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/storage/token_storage.dart';
import 'package:suska_starter/features/auth/data/auth_models.dart';

/// Autentikasi SSOT UIN Suska.
///
/// Kontrak mengikuti `docs/PANDUAN_SSOT_MOBILE.md` (tim SDM-BE):
/// Native Google Sign-In → `POST /authKJNPFj4389h3gniujs/google/mobile`
/// `{id_token, platform, app_id}` (+`X-Device-ID`) → JSON
/// `{status:1, data:{access_token(~30 hari), refresh_token, user{...}}}` →
/// simpan di Keystore/Keychain via [TokenStorage].
class AuthRepository {
  AuthRepository({required this._tokenStorage, Dio? ssotDio})
      : _ssotDio = ssotDio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.ssotUrl,
                connectTimeout: AppConfig.ssotTimeout,
                receiveTimeout: AppConfig.ssotTimeout,
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  final TokenStorage _tokenStorage;
  final Dio _ssotDio;

  /// Web Client ID SSOT — audience `id_token` (PANDUAN §2; HARUS sama
  /// dengan `xconfig.yaml` SDM Backend). Milik SSOT, SAMA untuk semua
  /// aplikasi kampus: jangan diganti per aplikasi. Yang per aplikasi adalah
  /// client Android (package + SHA-1) dan client iOS — lihat
  /// `docs/google-sign-in-setup.md`.
  static const _webClientId = '263220023664-095mcq19vsna1t6jomj5i9jm51fpd8ks'
      '.apps.googleusercontent.com';

  /// Endpoint login Google mobile (PANDUAN §3.1).
  static const _loginPath = '/authKJNPFj4389h3gniujs/google/mobile';

  /// SDK legacy (v6) dikonfigurasi lewat konstruktor.
  final GoogleSignIn _google = GoogleSignIn(serverClientId: _webClientId);

  Future<void> initialize() async {
    // v6 tidak butuh inisialisasi eksplisit.
  }

  Future<bool> get hasSession => _tokenStorage.hasSession;

  Future<AuthUser?> get currentUser async {
    final raw = await _tokenStorage.userJson;
    if (raw == null) return null;
    return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Login penuh: Google → SSOT → simpan JWT + user.
  Future<AuthUser> signIn() async {
    late final GoogleSignInAccount account;
    try {
      account = await obtainGoogleAccount(
        lightweight: _google.signInSilently,
        interactive: () async {
          final a = await _google.signIn();
          if (a == null) {
            // v6: null = user menutup dialog.
            throw const AuthException('Login Google dibatalkan.');
          }
          return a;
        },
      );
    } on PlatformException catch (e) {
      throw AuthException(friendlyGoogleSignInMessage(e));
    }
    final idToken = (await account.authentication).idToken;
    if (idToken == null) {
      throw const AuthException('Google tidak mengembalikan ID token');
    }

    final deviceId = await _tokenStorage.deviceId();

    late final Response<Map<String, dynamic>> res;
    try {
      res = await _ssotDio.post<Map<String, dynamic>>(
        _loginPath,
        // Payload PANDUAN §3.1 (+ email/name/picture — superset aman,
        // diabaikan server bila tak dipakai).
        data: {
          'id_token': idToken,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'app_id': AppConfig.appId,
          'email': account.email,
          'name': account.displayName ?? '',
          'picture': account.photoUrl,
        },
        options: Options(headers: {'X-Device-ID': deviceId}),
      );
    } on DioException catch (e) {
      throw AuthException(ssotLoginErrorMessage(e));
    }

    final body = res.data;
    if (body == null || body['status'] != 1) {
      throw AuthException(
        body?['message'] as String? ?? 'Login SSOT gagal',
      );
    }

    final data = body['data'] as Map<String, dynamic>;
    final accessToken = data['access_token'] as String?;
    if (accessToken == null) {
      throw const AuthException('SSOT tidak mengembalikan access_token');
    }

    final user =
        AuthUser.fromJson(data['user'] as Map<String, dynamic>? ?? const {});

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: data['refresh_token'] as String?,
    );
    await _tokenStorage.saveUserJson(jsonEncode(user.toJson()));

    return user;
  }

  /// Validasi token ke SSOT — `GET /v1/auth/validate-token` (PANDUAN §4.1).
  /// 401 berarti kedaluwarsa/dicabut (force-logout dari server).
  Future<bool> validateToken() async {
    final token = await _tokenStorage.accessToken;
    if (token == null) return false;
    try {
      final res = await _ssotDio.get<Map<String, dynamic>>(
        '/v1/auth/validate-token',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data?['status'] == 1;
    } on DioException {
      return false;
    }
  }

  /// Logout: cabut token di server (`POST /v1/auth/logout`, PANDUAN §5,
  /// best-effort), keluar dari Google, lalu hapus sesi lokal.
  Future<void> signOut() async {
    final token = await _tokenStorage.accessToken;
    if (token != null) {
      try {
        await _ssotDio.post<Map<String, dynamic>>(
          '/v1/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } on DioException {
        // Server tak terjangkau (intranet) — tetap lanjut logout lokal.
      }
    }
    try {
      await _google.signOut();
    } on Exception {
      // Sign-out Google gagal bukan alasan menahan logout lokal.
    }
    await _tokenStorage.clear();
  }
}

/// Ambil akun Google: coba jalur silent (lightweight) dulu, baru flow
/// interaktif. Jalur silent tidak memicu UI reauth GMS yang bermasalah di
/// sebagian emulator/akun Workspace.
Future<GoogleSignInAccount> obtainGoogleAccount({
  required Future<GoogleSignInAccount?> Function() lightweight,
  required Future<GoogleSignInAccount> Function() interactive,
}) async {
  try {
    final silent = await lightweight();
    if (silent != null) return silent;
  } on Exception {
    // Jalur silent hanya optimasi — kegagalan apa pun lanjut ke interaktif.
  }
  return interactive();
}

/// Pesan ramah-user untuk kegagalan di sisi Google Sign-In (sebelum
/// menyentuh backend) — melengkapi tabel PANDUAN §6 yang hanya mencakup
/// error HTTP SSOT.
String friendlyGoogleSignInMessage(PlatformException e) {
  return switch (e.code) {
    'sign_in_canceled' => 'Login Google dibatalkan.',
    'network_error' =>
      'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.',
    _ => 'Login Google gagal'
        '${(e.message?.isEmpty ?? true) ? '' : ' (${e.message})'}. '
        'Silakan coba lagi.',
  };
}

/// Pesan error login SSOT ramah-user sesuai tabel PANDUAN §6.
///
/// Alasan dari server dibaca dari `message`, lalu `error_message` — SSOT
/// nyata menjawab 401 sebagai `{status:0, rc:401, error_message:...}`.
String ssotLoginErrorMessage(DioException e) {
  final status = e.response?.statusCode;
  final data = e.response?.data;
  String? field(String key) {
    if (data is! Map) return null;
    final v = data[key];
    return v is String && v.trim().isNotEmpty ? v : null;
  }

  final serverMessage = field('message') ?? field('error_message');
  return switch (status) {
    400 || 401 =>
      serverMessage ?? 'Login Google tidak valid. Silakan coba lagi.',
    403 => serverMessage ??
        'Akun Anda non-aktif atau belum diberi hak akses. '
            'Hubungi admin SDM.',
    404 => 'Akun Anda belum terdaftar di SDM. Hubungi admin SDM.',
    _ => serverMessage ?? 'Tidak dapat terhubung ke server SSOT.',
  };
}

/// Error autentikasi dengan pesan yang aman ditampilkan ke user.
final class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
