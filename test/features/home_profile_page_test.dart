import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/settings/text_scale_cubit.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';
import 'package:suska_starter/features/auth/data/auth_models.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';
import 'package:suska_starter/features/home/view/home_page.dart';
import 'package:suska_starter/features/profile/view/profile_page.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late AuthCubit authCubit;
  late TextScaleCubit textScaleCubit;

  const user = AuthUser(
    idSdm: 'S1',
    email: 'pegawai@uin-suska.ac.id',
    namaSdm: 'Pegawai Contoh',
    nip: '199001012020121001',
    unitId: 'U1',
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = _MockAuthRepository();
    when(() => repository.signOut()).thenAnswer((_) async {});
    authCubit = AuthCubit(repository: repository);
    textScaleCubit = TextScaleCubit();
  });

  tearDown(() async {
    await authCubit.close();
    await textScaleCubit.close();
  });

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider.value(value: textScaleCubit),
        ],
        child: MaterialApp(home: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('HomePage', () {
    testWidgets('sapaan sesuai jam + nama user yang login', (tester) async {
      authCubit.emit(
        const AuthState(status: AuthStatus.authenticated, user: user),
      );

      await pump(tester, HomePage(now: DateTime(2026, 8, 20, 8)));

      expect(find.text('Selamat Pagi!'), findsOneWidget);
      expect(find.text('Pegawai Contoh'), findsOneWidget);
    });

    testWidgets('nama kosong -> "Pengguna", bukan teks kosong',
        (tester) async {
      await pump(tester, HomePage(now: DateTime(2026, 8, 20, 8)));

      expect(find.text('Pengguna'), findsOneWidget);
    });
  });

  group('ProfilePage', () {
    testWidgets('menampilkan data akun dan versi aplikasi', (tester) async {
      authCubit.emit(
        const AuthState(status: AuthStatus.authenticated, user: user),
      );

      await pump(tester, const ProfilePage());

      expect(find.text('Pegawai Contoh'), findsOneWidget);
      expect(find.text('199001012020121001'), findsOneWidget);
      expect(find.text('pegawai@uin-suska.ac.id'), findsOneWidget);
      expect(
        find.text('Versi ${AppConfig.appVersion} (${AppConfig.appBuild})'),
        findsOneWidget,
      );
    });

    testWidgets('data yang tidak ada tampil "-"', (tester) async {
      await pump(tester, const ProfilePage());

      // Nama, NIP, dan email kosong.
      expect(find.text('-'), findsNWidgets(3));
    });

    testWidgets('Ukuran Teks: pilih "Sangat Besar" -> skala 1.3 tersimpan',
        (tester) async {
      await pump(tester, const ProfilePage());

      await tester.tap(find.text('Ukuran Teks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sangat Besar'));
      await tester.pumpAndSettle();

      expect(textScaleCubit.state, 1.3);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble(TextScaleCubit.prefsKey), 1.3);
    });

    testWidgets('Keluar meminta konfirmasi dulu', (tester) async {
      authCubit.emit(
        const AuthState(status: AuthStatus.authenticated, user: user),
      );
      await pump(tester, const ProfilePage());

      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();
      verifyNever(() => repository.signOut());

      await tester.tap(find.text('Ya, Keluar'));
      await tester.pumpAndSettle();

      verify(() => repository.signOut()).called(1);
      expect(authCubit.state.status, AuthStatus.unauthenticated);
    });
  });
}
