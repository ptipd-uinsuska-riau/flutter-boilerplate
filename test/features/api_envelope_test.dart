import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/core/api/api_envelope.dart';

DioException _badResponse(Map<String, dynamic> data) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response<Map<String, dynamic>>(
      requestOptions: req,
      data: data,
      statusCode: 400,
    ),
  );
}

void main() {
  group('apiErrorMessage — konvensi backend tidak seragam', () {
    test('cuti: detail kalimat di `error` menang atas message generik', () {
      final msg = apiErrorMessage(
        _badResponse(const {
          'message': 'Internal Server Error',
          'error': 'Leave start date must be at least 1 day in the future',
        }),
      );
      expect(msg, 'Leave start date must be at least 1 day in the future');
    });

    test('dinas luar: `error` kode mesin diabaikan → pakai `message`', () {
      final msg = apiErrorMessage(
        _badResponse(const {
          'message': 'File dokumen (document) wajib diupload',
          'error': 'validation_error',
        }),
      );
      expect(msg, 'File dokumen (document) wajib diupload');
    });

    test('dinas luar 404: `not_found` diabaikan → pakai `message`', () {
      final msg = apiErrorMessage(
        _badResponse(const {
          'message': 'business trip not found',
          'error': 'not_found',
        }),
      );
      expect(msg, 'business trip not found');
    });

    test('ApiException dikembalikan apa adanya', () {
      expect(apiErrorMessage(const ApiException('Pesan spesifik')),
          'Pesan spesifik');
    });

    test('error jaringan → pesan koneksi ramah', () {
      final req = RequestOptions(path: '/x');
      final e = DioException(
        requestOptions: req,
        type: DioExceptionType.connectionTimeout,
      );
      expect(
        apiErrorMessage(e),
        'Koneksi bermasalah. Periksa jaringan Anda.',
      );
    });
  });
}
