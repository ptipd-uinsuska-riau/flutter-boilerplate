import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suska_starter/app/router.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('transisi splash → Beranda', () {
    testWidgets('fadePage: di iOS halaman tidak bergeser dari kanan',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final router = GoRouter(
        initialLocation: '/welcome',
        routes: [
          GoRoute(
            path: '/welcome',
            pageBuilder: (_, state) => fadePage(
              key: state.pageKey,
              child: const Scaffold(key: Key('splash'), body: Text('SPLASH')),
            ),
          ),
          GoRoute(
            path: '/',
            pageBuilder: (_, state) => fadePage(
              key: state.pageKey,
              child: const Scaffold(key: Key('home'), body: Text('HOME')),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      final screen = tester.getRect(find.byKey(const Key('splash')));

      router.go('/');
      await tester.pump();
      // Tengah transisi: transisi geser Cupertino akan menaruh halaman baru
      // di kanan layar dan menggeser splash ke kiri.
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.getRect(find.byKey(const Key('home'))), screen);
      final splash = find.byKey(const Key('splash'));
      if (splash.evaluate().isNotEmpty) {
        expect(tester.getRect(splash), screen);
      }

      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('SPLASH'), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    });

    test('router asli: /welcome & kerangka tab memakai pageBuilder pudar', () {
      final cubit = AuthCubit(repository: _MockAuthRepository());
      final router = buildRouter(cubit);
      addTearDown(() async {
        router.dispose();
        await cubit.close();
      });

      final routes = router.configuration.routes;
      final welcome = routes
          .whereType<GoRoute>()
          .firstWhere((route) => route.path == '/welcome');
      final shell = routes.whereType<StatefulShellRoute>().single;

      expect(welcome.pageBuilder, isNotNull);
      expect(shell.pageBuilder, isNotNull);
    });
  });
}
