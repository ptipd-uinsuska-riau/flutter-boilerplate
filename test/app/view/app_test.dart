import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';
import 'package:suska_starter/features/auth/view/login_page.dart';

import '../../helpers/helpers.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LoginPage', () {
    testWidgets('menampilkan nama aplikasi dari AppConfig dan tombol masuk',
        (tester) async {
      await tester.pumpAppWithAuth(
        const LoginPage(),
        AuthCubit(repository: _MockAuthRepository()),
      );

      expect(find.text(AppConfig.appName), findsOneWidget);
      expect(find.textContaining('Masuk dengan akun'), findsOneWidget);
    });
  });
}
