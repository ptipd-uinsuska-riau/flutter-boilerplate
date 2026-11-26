import 'package:dio/dio.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/storage/token_storage.dart';

/// Refresh access token via SSOT (be-sdm).
///
/// Kontrak:
/// - `POST {ssotUrl}/v1/auth/refresh-token` body `{refresh_token}`
/// - Respons FLAT (bukan nested `data`):
///   `{status, rc, access_token, refresh_token, token_type?, expires_in?}`
/// - 401/403 → refresh token ditolak server → sesi dihapus (harus login
///   ulang). Error jaringan → sesi TIDAK dihapus.
class TokenRefresher {
  TokenRefresher({required this._tokenStorage, Dio? ssotDio})
      : _dio = ssotDio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.ssotUrl,
                connectTimeout: AppConfig.ssotTimeout,
                receiveTimeout: AppConfig.ssotTimeout,
              ),
            );

  final TokenStorage _tokenStorage;
  final Dio _dio;

  /// Mengembalikan `true` bila token berhasil diperbarui.
  Future<bool> refresh() async {
    final refreshToken = await _tokenStorage.refreshToken;
    if (refreshToken == null) return false;

    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/refresh-token',
        data: {'refresh_token': refreshToken},
        // X-Device-ID konsisten (PANDUAN_SSOT_MOBILE §5 — sesi per-device).
        options: Options(
          headers: {'X-Device-ID': await _tokenStorage.deviceId()},
        ),
      );

      final body = res.data;
      final newAccess = body?['access_token'] as String?;
      if (newAccess == null) return false;

      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: body?['refresh_token'] as String?,
      );
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        // Refresh token ditolak server — wajib login ulang.
        await _tokenStorage.clear();
      }
      return false;
    }
  }
}
