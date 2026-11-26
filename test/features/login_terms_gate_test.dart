import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suska_starter/core/storage/terms_storage.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';
import 'package:suska_starter/features/auth/view/login_page.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository repository;
  late AuthCubit authCubit;

  setUp(() {
    repository = _MockAuthRepository();
    authCubit = AuthCubit(repository: repository);
  });

  Future<void> pumpLogin(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
        GoRoute(path: '/terms', builder: (_, _) => const Text('TERMS-DUMMY')),
      ],
    );
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: TermsStorage(),
        child: BlocProvider.value(
          value: authCubit,
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('belum setuju syarat -> tombol masuk membuka Terms, bukan login',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await pumpLogin(tester);
    await tester.tap(find.textContaining('Masuk dengan akun'));
    await tester.pumpAndSettle();

    expect(find.text('TERMS-DUMMY'), findsOneWidget);
    verifyNever(() => repository.signIn());
  });

  testWidgets('sudah setuju syarat -> tombol masuk memanggil signIn',
      (tester) async {
    SharedPreferences.setMockInitialValues({'terms_accepted': true});
    when(() => repository.signIn()).thenThrow(Exception('stop di sini'));

    await pumpLogin(tester);
    await tester.tap(find.textContaining('Masuk dengan akun'));
    await tester.pumpAndSettle();

    expect(find.text('TERMS-DUMMY'), findsNothing);
    verify(() => repository.signIn()).called(1);
  });
}
