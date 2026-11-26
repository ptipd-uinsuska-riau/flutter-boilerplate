import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/app/router.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';

void main() {
  group('redirectFor', () {
    const unknown = AuthState();
    const unauthed = AuthState(status: AuthStatus.unauthenticated);
    const authed = AuthState(status: AuthStatus.authenticated);

    test('status unknown -> tahan di /welcome (splash saat cek sesi)', () {
      expect(redirectFor(unknown, '/'), '/welcome');
      expect(redirectFor(unknown, '/welcome'), isNull);
    });

    test('belum login -> dipaksa ke /welcome', () {
      expect(redirectFor(unauthed, '/'), '/welcome');
      expect(redirectFor(unauthed, '/sample'), '/welcome');
      expect(redirectFor(unauthed, '/profile'), '/welcome');
      expect(redirectFor(unauthed, '/welcome'), isNull);
      expect(redirectFor(unauthed, '/login'), isNull);
    });

    test('sudah login di /welcome atau /login -> ke beranda', () {
      expect(redirectFor(authed, '/welcome'), '/');
      expect(redirectFor(authed, '/login'), '/');
    });

    test('sudah login -> navigasi tidak diblokir', () {
      expect(redirectFor(authed, '/'), isNull);
      expect(redirectFor(authed, '/sample'), isNull);
      expect(redirectFor(authed, '/sample/form'), isNull);
      expect(redirectFor(authed, '/profile'), isNull);
    });

    test('halaman legal dapat diakses sebelum login', () {
      expect(redirectFor(unauthed, '/terms'), isNull);
      expect(redirectFor(unauthed, '/privacy-policy'), isNull);
      // Setelah login pun tidak dilempar balik.
      expect(redirectFor(authed, '/terms'), isNull);
      expect(redirectFor(authed, '/privacy-policy'), isNull);
    });

    test('/force-update tidak pernah di-redirect (cek versi pra-login)', () {
      expect(redirectFor(unknown, '/force-update'), isNull);
      expect(redirectFor(unauthed, '/force-update'), isNull);
      expect(redirectFor(authed, '/force-update'), isNull);
    });
  });
}
