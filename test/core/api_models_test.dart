import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/core/api/api_envelope.dart';

Response<Map<String, dynamic>> _res(Map<String, dynamic> body) => Response(
      requestOptions: RequestOptions(path: '/test'),
      data: body,
    );

void main() {
  group('unwrapEnvelope', () {
    test('mengembalikan data saat status == 1', () {
      final result = unwrapEnvelope(
        _res({
          'status': 1,
          'rc': 200,
          'message': 'OK',
          'data': {'x': 42},
        }),
        (data) => (data as Map<String, dynamic>)['x'],
      );
      expect(result, 42);
    });

    test('melempar ApiException dengan pesan backend saat status != 1', () {
      expect(
        () => unwrapEnvelope(
          _res({'status': 0, 'rc': 400, 'message': 'Token tidak valid'}),
          (data) => data,
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Token tidak valid'),
        ),
      );
    });
  });

  group('apiErrorMessage', () {
    test('memakai message body backend pada DioException 4xx', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/attendance/clock-in'),
        response: _res(const {
          'status': 0,
          'rc': 400,
          'message': 'Wajah tidak cocok dengan data terdaftar (skor: 39%).',
        }),
      );
      expect(
        apiErrorMessage(err, fallback: 'Gagal'),
        'Wajah tidak cocok dengan data terdaftar (skor: 39%).',
      );
    });

    test('pesan jaringan saat connectionError tanpa body', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      );
      expect(
        apiErrorMessage(err, fallback: 'Gagal'),
        'Koneksi bermasalah. Periksa jaringan Anda.',
      );
    });

    test('ApiException memakai pesannya langsung', () {
      expect(
        apiErrorMessage(const ApiException('Sesi berakhir')),
        'Sesi berakhir',
      );
    });
  });
}
