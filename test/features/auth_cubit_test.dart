import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suska_starter/core/cache/memory_cache.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';
import 'package:suska_starter/features/auth/data/auth_models.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthCubit', () {
    late AuthRepository repository;

    const user = AuthUser(
      idSdm: 'S1',
      email: 'pegawai@uin.ac.id',
      namaSdm: 'Pegawai Contoh',
      nip: '123',
      unitId: 'U1',
    );

    setUp(() {
      repository = _MockAuthRepository();
      when(() => repository.initialize()).thenAnswer((_) async {});
      when(() => repository.signIn()).thenAnswer((_) async => user);
      when(() => repository.signOut()).thenAnswer((_) async {});
    });

    test('checkSession tanpa sesi -> unauthenticated', () async {
      when(() => repository.hasSession).thenAnswer((_) async => false);

      final cubit = AuthCubit(repository: repository);
      await cubit.checkSession();

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.user, isNull);
    });

    test('checkSession dengan sesi tersimpan -> authenticated + user',
        () async {
      when(() => repository.hasSession).thenAnswer((_) async => true);
      when(() => repository.currentUser).thenAnswer((_) async => user);

      final cubit = AuthCubit(repository: repository);
      await cubit.checkSession();

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user, user);
    });

    test('signIn sukses -> authenticating lalu authenticated', () async {
      final cubit = AuthCubit(repository: repository);
      final statuses = <AuthStatus>[];
      final sub = cubit.stream.listen((s) => statuses.add(s.status));

      await cubit.signIn();
      await pumpEventQueue();
      await sub.cancel();

      expect(statuses, [AuthStatus.authenticating, AuthStatus.authenticated]);
      expect(cubit.state.user, user);
    });

    test('signIn gagal -> unauthenticated + pesan yang aman ditampilkan',
        () async {
      when(() => repository.signIn())
          .thenThrow(const AuthException('Login Google dibatalkan.'));

      final cubit = AuthCubit(repository: repository);
      await cubit.signIn();

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.errorMessage, 'Login Google dibatalkan.');
    });

    test('signOut menghapus user dan MemoryCache', () async {
      MemoryCache.set('apa-saja', 1);

      final cubit = AuthCubit(repository: repository);
      await cubit.signIn();
      await cubit.signOut();

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.user, isNull);
      expect(MemoryCache.get<int>('apa-saja'), isNull);
      verify(() => repository.signOut()).called(1);
    });
  });
}
