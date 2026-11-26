import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:suska_starter/core/api/api_client.dart';
import 'package:suska_starter/core/api/api_envelope.dart';

final class VersionCheck extends Equatable {
  const VersionCheck({
    required this.updateAvailable,
    required this.isRequired,
    required this.latestVersion,
    this.latestBuild,
    this.minBuild,
    this.currentVersion,
    this.downloadUrl,
    this.releaseNotes,
  });

  /// Defensif: tipe tak terduga dari server jatuh ke nilai aman (tanpa
  /// cast) — cek versi tak boleh bisa membuat aplikasi crash.
  factory VersionCheck.fromJson(Map<String, dynamic> json) => VersionCheck(
        updateAvailable: json['update_available'] == true,
        isRequired: json['is_required'] == true,
        latestVersion: _str(json['latest_version']) ?? '',
        latestBuild: _int(json['latest_build']),
        minBuild: _int(json['min_build']),
        currentVersion: _str(json['current_version']),
        downloadUrl: _str(json['download_url']),
        releaseNotes: _str(json['release_notes']),
      );

  static String? _str(dynamic value) => value is String ? value : null;

  static int? _int(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  /// Salinan dengan status update diganti — dipakai saat APLIKASI yang
  /// memutuskan ada update (build lebih lama; lihat `decideUpdate`).
  VersionCheck copyWith({bool? updateAvailable, bool? isRequired}) =>
      VersionCheck(
        updateAvailable: updateAvailable ?? this.updateAvailable,
        isRequired: isRequired ?? this.isRequired,
        latestVersion: latestVersion,
        latestBuild: latestBuild,
        minBuild: minBuild,
        currentVersion: currentVersion,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
      );

  final bool updateAvailable;
  final bool isRequired;
  final String latestVersion;
  final int? latestBuild;

  /// Build (versionCode) terendah yang masih diizinkan backend — `null`
  /// bila belum ada batas.
  final int? minBuild;
  final String? currentVersion;
  final String? downloadUrl;
  final String? releaseNotes;

  @override
  List<Object?> get props => [
        updateAvailable,
        isRequired,
        latestVersion,
        latestBuild,
        minBuild,
        currentVersion,
        downloadUrl,
        releaseNotes,
      ];
}

/// Cek versi aplikasi.
///
/// Backend aplikasi perlu menyediakan `GET /app/check-version` yang
/// menjawab `{status:1, data:{update_available, is_required,
/// latest_version, latest_build, min_build, download_url, release_notes}}`.
/// Selama endpoint itu belum ada, cek versi gagal diam-diam dan aplikasi
/// tetap jalan (lihat `App._checkAppVersion`).
class AppVersionApi {
  AppVersionApi(this._client);

  final ApiClient _client;

  Dio get _dio => _client.dio;

  /// Cek update (endpoint publik, tanpa auth).
  ///
  /// [build] = versionCode terpasang; backend memakainya untuk menghitung
  /// `is_required` terhadap `min_build`.
  Future<VersionCheck> checkVersion({
    required String platform,
    required String version,
    required int build,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/app/check-version',
      queryParameters: {
        'platform': platform,
        'version': version,
        'build': build,
      },
    );
    return unwrapEnvelope(
      res,
      (data) => VersionCheck.fromJson(data as Map<String, dynamic>),
    );
  }
}
