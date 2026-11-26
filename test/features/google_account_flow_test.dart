import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';

class _MockAccount extends Mock implements GoogleSignInAccount {}

void main() {
  group('obtainGoogleAccount', () {
    test('jalur silent berhasil -> flow interaktif tidak dipanggil',
        () async {
      final silent = _MockAccount();
      var interactiveCalled = false;

      final account = await obtainGoogleAccount(
        lightweight: () async => silent,
        interactive: () async {
          interactiveCalled = true;
          return _MockAccount();
        },
      );

      expect(account, same(silent));
      expect(interactiveCalled, isFalse);
    });

    test('silent null -> fallback ke flow interaktif', () async {
      final interactive = _MockAccount();

      final account = await obtainGoogleAccount(
        lightweight: () async => null,
        interactive: () async => interactive,
      );

      expect(account, same(interactive));
    });

    test('silent melempar -> tetap fallback ke interaktif', () async {
      final interactive = _MockAccount();

      final account = await obtainGoogleAccount(
        lightweight: () async =>
            throw PlatformException(code: 'sign_in_required'),
        interactive: () async => interactive,
      );

      expect(account, same(interactive));
    });
  });
}
