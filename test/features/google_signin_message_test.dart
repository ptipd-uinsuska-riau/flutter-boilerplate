import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';

void main() {
  group('friendlyGoogleSignInMessage (PlatformException v6)', () {
    test('dibatalkan user -> pesan singkat tanpa jargon', () {
      expect(
        friendlyGoogleSignInMessage(
          PlatformException(code: 'sign_in_canceled'),
        ),
        'Login Google dibatalkan.',
      );
    });

    test('jaringan bermasalah -> arahkan cek koneksi', () {
      expect(
        friendlyGoogleSignInMessage(
          PlatformException(code: 'network_error'),
        ),
        'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.',
      );
    });

    test('kode lain -> pesan umum + detail', () {
      final msg = friendlyGoogleSignInMessage(
        PlatformException(code: 'sign_in_failed', message: 'status 12500'),
      );
      expect(msg, startsWith('Login Google gagal'));
      expect(msg, contains('status 12500'));
    });
  });
}
