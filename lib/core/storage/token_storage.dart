import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan token JWT di Android Keystore/iOS Keychain via
/// [FlutterSecureStorage] — token tidak pernah disimpan sebagai teks biasa.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUser = 'user';
  static const _kDeviceId = 'device_id';

  Future<String?> get accessToken => _storage.read(key: _kAccessToken);
  Future<String?> get refreshToken => _storage.read(key: _kRefreshToken);

  /// JSON string data user SSOT.
  Future<String?> get userJson => _storage.read(key: _kUser);

  Future<void> saveUserJson(String json) =>
      _storage.write(key: _kUser, value: json);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _kRefreshToken, value: refreshToken);
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kUser);
  }

  Future<bool> get hasSession async => (await accessToken) != null;

  /// ID perangkat persisten untuk header `X-Device-ID` (PANDUAN_SSOT_MOBILE
  /// §3.1/§5 — manajemen sesi per-perangkat). Dibuat sekali, konsisten
  /// sepanjang instalasi.
  Future<String> deviceId() async {
    final existing = await _storage.read(key: _kDeviceId);
    if (existing != null) return existing;
    final generated =
        'app-${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}'
        '-${identityHashCode(this).toRadixString(16)}';
    await _storage.write(key: _kDeviceId, value: generated);
    return generated;
  }
}
