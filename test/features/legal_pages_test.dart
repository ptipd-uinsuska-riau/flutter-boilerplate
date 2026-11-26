import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/storage/terms_storage.dart';
import 'package:suska_starter/features/legal/view/privacy_policy_page.dart';
import 'package:suska_starter/features/legal/view/terms_page.dart';

void main() {
  group('TermsPage', () {
    late TermsStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = TermsStorage();
    });

    Future<void> pumpTerms(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/terms',
        routes: [
          GoRoute(path: '/terms', builder: (_, _) => const TermsPage()),
          GoRoute(
            path: '/login',
            builder: (_, _) => const Text('LOGIN-DUMMY'),
          ),
          GoRoute(
            path: '/privacy-policy',
            builder: (_, _) => const Text('PRIVACY-DUMMY'),
          ),
        ],
      );
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: storage,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('tombol setuju nonaktif sebelum checkbox dicentang',
        (tester) async {
      await pumpTerms(tester);

      expect(find.text('Syarat & Ketentuan'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Setuju & Lanjutkan'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('centang + setuju -> simpan persetujuan lalu ke login',
        (tester) async {
      await pumpTerms(tester);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Setuju & Lanjutkan'));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN-DUMMY'), findsOneWidget);
      expect(await storage.hasAccepted(), isTrue);
    });

    testWidgets('link kebijakan privasi membuka halaman privacy',
        (tester) async {
      await pumpTerms(tester);

      await tester.scrollUntilVisible(
        find.text('Baca Kebijakan Privasi'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Baca Kebijakan Privasi'));
      await tester.pumpAndSettle();

      expect(find.text('PRIVACY-DUMMY'), findsOneWidget);
    });
  });

  group('PrivacyPolicyPage', () {
    testWidgets('menampilkan judul dan pembukaan kebijakan', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PrivacyPolicyPage()),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Kebijakan Privasi Aplikasi ${AppConfig.appName}'),
        findsOneWidget,
      );
      expect(find.textContaining('UU PDP'), findsWidgets);
    });
  });
}
