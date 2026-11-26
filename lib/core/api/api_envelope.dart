import 'package:dio/dio.dart';

/// Backend kampus (termasuk be-sdm) membungkus respons dalam envelope
/// `{status, rc, message, data}` dengan `status == 1` berarti sukses.
///
/// Helper ini membongkar envelope tersebut dan melempar [ApiException]
/// dengan pesan backend bila gagal.
T unwrapEnvelope<T>(
  Response<Map<String, dynamic>> response,
  T Function(dynamic data) mapper,
) {
  final body = response.data;
  if (body == null) {
    throw const ApiException('Respons kosong dari server');
  }
  if (body['status'] != 1) {
    throw ApiException(
      body['message'] as String? ?? 'Permintaan gagal',
      rc: body['rc'] as int?,
    );
  }
  return mapper(body['data']);
}

/// Error API dengan pesan backend yang aman ditampilkan ke user.
final class ApiException implements Exception {
  const ApiException(this.message, {this.rc});

  final String message;
  final int? rc;

  @override
  String toString() => message;
}

/// Pesan error ramah untuk ditampilkan ke user dari sembarang [error].
///
/// PENTING: untuk status non-2xx (mis. 400 "Wajah tidak cocok..."), dio
/// melempar [DioException] SEBELUM [unwrapEnvelope] dipanggil, sehingga
/// `error.toString()` berisi teks Dio yang panjang — bukan pesan backend.
/// Helper ini mengambil `message` dari body envelope bila ada.
String apiErrorMessage(Object error, {String fallback = 'Terjadi kesalahan'}) {
  if (error is ApiException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      // Konvensi backend tidak seragam:
      // - modul cuti: DETAIL ada di `error`, `message` generik ("Internal
      //   Server Error") → pakai `error`;
      // - modul dinas luar: detail di `message`, `error` hanya KODE mesin
      //   ("validation_error"/"not_found") → pakai `message`.
      // Heuristik: `error` dipakai HANYA bila tampak kalimat manusia
      // (mengandung spasi); kode snake_case satu-kata diabaikan.
      final detail = data['error'];
      if (detail is String && detail.trim().contains(' ')) return detail;
      if (data['message'] is String) return data['message'] as String;
    }
    const network = {
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    };
    if (network.contains(error.type)) {
      return 'Koneksi bermasalah. Periksa jaringan Anda.';
    }
  }
  return fallback;
}
