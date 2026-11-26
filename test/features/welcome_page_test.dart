import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/storage/terms_storage.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';
import 'package:suska_starter/features/auth/view/welcome_page.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthCubit authCubit;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    authCubit = AuthCubit(repository: _MockAuthRepository());
  });

  Future<void> pumpWelcome(WidgetTester tester, {bool settle = true}) async {
    final router = GoRouter(
      initialLocation: '/welcome',
      routes: [
        GoRoute(path: '/welcome', builder: (_, _) => const WelcomePage()),
        GoRoute(path: '/login', builder: (_, _) => const Text('LOGIN-DUMMY')),
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
    // Spinner beranimasi tanpa henti — pumpAndSettle tidak akan selesai.
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  testWidgets('status unknown -> spinner tanpa tombol Mulai', (tester) async {
    // AuthState default berstatus unknown.
    await pumpWelcome(tester, settle: false);

    expect(find.text(AppConfig.appName), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Mulai'), findsNothing);
  });

  testWidgets('belum login + belum setuju syarat -> Mulai membuka Terms',
      (tester) async {
    authCubit.emit(const AuthState(status: AuthStatus.unauthenticated));

    await pumpWelcome(tester);
    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(find.text('TERMS-DUMMY'), findsOneWidget);
  });

  testWidgets('belum login + sudah setuju -> Mulai membuka Login',
      (tester) async {
    SharedPreferences.setMockInitialValues({'terms_accepted': true});
    authCubit.emit(const AuthState(status: AuthStatus.unauthenticated));

    await pumpWelcome(tester);
    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN-DUMMY'), findsOneWidget);
  });
}
