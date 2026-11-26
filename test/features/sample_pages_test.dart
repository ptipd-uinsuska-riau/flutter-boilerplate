import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suska_starter/core/api/api_envelope.dart';
import 'package:suska_starter/features/sample/data/sample_api.dart';
import 'package:suska_starter/features/sample/data/sample_models.dart';
import 'package:suska_starter/features/sample/view/sample_form_page.dart';
import 'package:suska_starter/features/sample/view/sample_list_page.dart';

class _MockSampleApi extends Mock implements SampleApi {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
    registerFallbackValue(
      SampleDraft(
        title: '',
        category: '',
        startDate: DateTime(2026),
        endDate: DateTime(2026),
      ),
    );
  });

  Future<void> pump(WidgetTester tester, SampleApi api, Widget page) async {
    // Viewport tinggi agar ListView membangun semua anak.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: api,
        child: MaterialApp(home: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SampleListPage', () {
    testWidgets('menampilkan kartu dari API dan menyaring lewat chip',
        (tester) async {
      await pump(
        tester,
        SampleApi(delay: Duration.zero),
        const SampleListPage(),
      );

      expect(find.text('Peminjaman Ruang Rapat'), findsOneWidget);
      expect(find.text('Permohonan Akun Email'), findsOneWidget);
      expect(find.text('20 Agu 2026'), findsOneWidget);

      await tester.tap(find.text('Disetujui').first);
      await tester.pumpAndSettle();

      expect(find.text('Permohonan Akun Email'), findsOneWidget);
      expect(find.text('Peminjaman Ruang Rapat'), findsNothing);
    });

    testWidgets('daftar kosong -> keadaan kosong', (tester) async {
      await pump(
        tester,
        SampleApi(seed: const [], delay: Duration.zero),
        const SampleListPage(),
      );

      expect(find.text('Belum ada pengajuan'), findsOneWidget);
    });

    testWidgets('gagal memuat -> pesan backend + Coba Lagi memuat ulang',
        (tester) async {
      final api = _MockSampleApi();
      when(() => api.changes).thenAnswer((_) => const Stream.empty());
      when(api.list).thenThrow(const ApiException('Server sedang sibuk'));

      await pump(tester, api, const SampleListPage());
      expect(find.text('Server sedang sibuk'), findsOneWidget);

      when(api.list).thenAnswer((_) async => const []);
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada pengajuan'), findsOneWidget);
    });
  });

  group('SampleFormPage', () {
    Future<void> pumpForm(WidgetTester tester, SampleApi api) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => context.push('/form'),
                child: const Text('BUKA'),
              ),
            ),
          ),
          GoRoute(path: '/form', builder: (_, _) => const SampleFormPage()),
        ],
      );
      await tester.pumpWidget(
        RepositoryProvider.value(
          value: api,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.tap(find.text('BUKA'));
      await tester.pumpAndSettle();
    }

    testWidgets('Kirim dengan formulir kosong -> pesan validasi',
        (tester) async {
      final api = _MockSampleApi();
      await pumpForm(tester, api);

      await tester.tap(find.text('Kirim'));
      await tester.pump();

      expect(find.text('Judul wajib diisi'), findsOneWidget);
      verifyNever(() => api.create(any()));
    });

    testWidgets('menampilkan semua isian', (tester) async {
      await pumpForm(tester, _MockSampleApi());

      for (final label in [
        'Judul',
        'Kategori',
        'Tanggal Mulai',
        'Tanggal Selesai',
        'Catatan',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });
  });
}
