import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';

DioException _err(int status, [Object? data]) {
  final req = RequestOptions(path: '/authKJNPFj4389h3gniujs/google/mobile');
  return DioException(
    requestOptions: req,
    response: Response<Object?>(
      requestOptions: req,
      statusCode: status,
      data: data,
    ),
  );
}

void main() {
  group('ssotLoginErrorMessage (POST google/mobile)', () {
    test('401 dgn field message -> tampilkan message server', () {
      expect(
        ssotLoginErrorMessage(
          _err(401, {'status': 0, 'message': 'Token ditolak'}),
        ),
        'Token ditolak',
      );
    });

    test('401 dgn field error_message (bentuk SSOT nyata) -> tampilkan', () {
      expect(
        ssotLoginErrorMessage(
          _err(401, {
            'status': 0,
            'rc': 401,
            'error_message': 'Invalid or expired ID token',
          }),
        ),
        'Invalid or expired ID token',
      );
    });

    test('message diutamakan bila keduanya ada', () {
      expect(
        ssotLoginErrorMessage(
          _err(400, {'message': 'Pesan utama', 'error_message': 'Cadangan'}),
        ),
        'Pesan utama',
      );
    });

    test('message kosong -> jatuh ke error_message', () {
      expect(
        ssotLoginErrorMessage(
          _err(401, {'message': '', 'error_message': 'Alasan asli'}),
        ),
        'Alasan asli',
      );
    });

    test('401 tanpa body -> pesan umum', () {
      expect(
        ssotLoginErrorMessage(_err(401)),
        'Login Google tidak valid. Silakan coba lagi.',
      );
    });

    test('403 dgn error_message -> tampilkan alasan server', () {
      expect(
        ssotLoginErrorMessage(_err(403, {'error_message': 'Akun diblokir'})),
        'Akun diblokir',
      );
    });

    test('404 -> selalu pesan belum terdaftar', () {
      expect(
        ssotLoginErrorMessage(_err(404, {'error_message': 'not found'})),
        'Akun Anda belum terdaftar di SDM. Hubungi admin SDM.',
      );
    });

    test('tanpa respons (offline) -> tidak dapat terhubung', () {
      expect(
        ssotLoginErrorMessage(
          DioException(requestOptions: RequestOptions(path: '/x')),
        ),
        'Tidak dapat terhubung ke server SSOT.',
      );
    });
  });
}
