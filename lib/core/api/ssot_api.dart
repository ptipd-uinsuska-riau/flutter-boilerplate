import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:suska_starter/core/api/api_envelope.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/storage/token_storage.dart';
import 'package:suska_starter/core/utils/jwt.dart';

/// Unit organisasi (master data SSOT).
final class OrgUnit extends Equatable {
  const OrgUnit({
    required this.id,
    required this.nama,
    required this.jenis,
    this.parentId,
  });

  factory OrgUnit.fromJson(Map<String, dynamic> json) => OrgUnit(
        id: json['id'] as String? ?? '',
        nama: json['nama'] as String? ?? '',
        jenis: json['jenis'] as String? ?? '',
        parentId: json['parent_id'] as String?,
      );

  final String id;
  final String nama;
  final String jenis;
  final String? parentId;

  @override
  List<Object?> get props => [id, nama, jenis, parentId];
}

/// Tautan foto profil bertanda tangan dari Storage Service SDM.
///
/// [url] kedaluwarsa ±5 menit dan diambil TANPA header Authorization;
/// [fileFoto] (ID berkas) stabil sampai foto diganti → kunci cache.
final class FotoTautan extends Equatable {
  const FotoTautan({required this.url, this.fileFoto});

  final String url;
  final String? fileFoto;

  @override
  List<Object?> get props => [url, fileFoto];
}

/// API data non-auth di be-sdm: profil user, data SDM lengkap, master data,
/// dan permission.
///
/// Data SDM lengkap dikembalikan sebagai `Map` dulu — struktur
/// `EmployeeCompleteData` sangat besar; model detail menyusul saat porting
/// screen Profil.
class SsotApi {
  SsotApi({required this._tokenStorage, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.ssotUrl,
                connectTimeout: AppConfig.ssotTimeout,
                receiveTimeout: AppConfig.ssotTimeout,
              ),
            );

  final TokenStorage _tokenStorage;
  final Dio _dio;

  Future<Options> _auth() async {
    final token = await _tokenStorage.accessToken;
    if (token == null) {
      throw const ApiException('Belum login — token tidak tersedia');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Profil ringan user login — `GET /client/me`.
  Future<Map<String, dynamic>> getMyProfile() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/client/me',
      options: await _auth(),
    );
    return unwrapEnvelope(res, (data) => data as Map<String, dynamic>);
  }

  /// Data SDM lengkap user login. Email diambil dari klaim JWT.
  /// `GET /internal/v1/sdm/detail?skema=complete&email={email}`.
  Future<Map<String, dynamic>> getMyCompleteProfile() async {
    final token = await _tokenStorage.accessToken;
    if (token == null) {
      throw const ApiException('Belum login — token tidak tersedia');
    }
    final email = decodeJwtPayload(token)?['email'] as String?;
    if (email == null) {
      throw const ApiException('Email tidak ditemukan di token');
    }
    final res = await _dio.get<Map<String, dynamic>>(
      '/internal/v1/sdm/detail',
      queryParameters: {'skema': 'complete', 'email': email},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return unwrapEnvelope(res, (data) => data as Map<String, dynamic>);
  }

  /// Tautan foto profil user login —
  /// `GET /internal/v1/self/profil/foto/tautan` →
  /// `{file_foto, url, expires_at}` (kontrak SDM 2026-11-17).
  ///
  /// `null` bila user belum punya foto / respons tak berisi URL. Jangan
  /// menyimpan `url` jangka panjang — minta ulang tiap hendak menampilkan.
  Future<FotoTautan?> getMyFotoTautan() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/internal/v1/self/profil/foto/tautan',
      options: await _auth(),
    );
    // Defensif: be-sdm umumnya membungkus dalam envelope, tapi kontrak
    // endpoint ini ditulis tanpa envelope — terima keduanya.
    final body = res.data;
    final data = body != null && body.containsKey('status')
        ? unwrapEnvelope(res, (data) => data)
        : body;
    if (data is! Map) return null;
    final url = data['url'];
    if (url is! String || !url.startsWith('http')) return null;
    final fileFoto = data['file_foto'];
    return FotoTautan(
      url: url,
      fileFoto: fileFoto is String && fileFoto.isNotEmpty ? fileFoto : null,
    );
  }

  /// Data SDM lengkap pegawai lain berdasarkan NIP.
  /// `GET /v1/sdm/detail?nip={nip}&skema=complete`.
  Future<Map<String, dynamic>> getEmployeeByNip(String nip) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/v1/sdm/detail',
      queryParameters: {'nip': nip, 'skema': 'complete'},
      options: await _auth(),
    );
    return unwrapEnvelope(res, (data) => data as Map<String, dynamic>);
  }

  // ─── Master data ────────────────────────────────────────────────────

  /// `GET /internal/v1/unit/list`
  Future<List<OrgUnit>> getUnits() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/internal/v1/unit/list',
      options: await _auth(),
    );
    return unwrapEnvelope(
      res,
      (data) => (data as List<dynamic>? ?? const [])
          .map((e) => OrgUnit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Anggota unit — `GET /internal/v1/unit/members?unit_id={unitId}`.
  Future<List<Map<String, dynamic>>> getUnitMembers(String unitId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/internal/v1/unit/members',
      queryParameters: {'unit_id': unitId},
      options: await _auth(),
    );
    return unwrapEnvelope(
      res,
      (data) =>
          (data as List<dynamic>? ?? const []).cast<Map<String, dynamic>>(),
    );
  }

  // ─── Permission ─────────────────────────────────────────────────────

  /// Cek satu permission — `POST /permission/check-permission`.
  /// Mengembalikan `false` (bukan throw) saat gagal.
  ///
  /// PERINGATAN: di aplikasi Presensia endpoint ini terbukti salah jawab.
  /// Untuk gating menu pakai [getUserPermissions] lalu `contains`.
  Future<bool> checkPermission(String permission) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/permission/check-permission',
        data: {'app_id': AppConfig.appId, 'permission': permission},
        options: await _auth(),
      );
      return unwrapEnvelope(
        res,
        (data) =>
            (data as Map<String, dynamic>)['has_permission'] as bool? ??
            false,
      );
    } on Exception {
      return false;
    }
  }

  /// Semua permission user untuk app ini —
  /// `GET /permission/user/permissions?app_id=`.
  Future<List<String>> getUserPermissions() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/permission/user/permissions',
      queryParameters: {'app_id': AppConfig.appId},
      options: await _auth(),
    );
    return unwrapEnvelope(
      res,
      (data) =>
          ((data as Map<String, dynamic>)['permissions'] as List<dynamic>? ??
                  const [])
              .cast<String>(),
    );
  }
}
