import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:suska_starter/core/api/api_envelope.dart';
import 'package:suska_starter/core/cache/memory_cache.dart';
import 'package:suska_starter/features/sample/cubit/sample_cubit.dart';
import 'package:suska_starter/features/sample/cubit/sample_form_cubit.dart';
import 'package:suska_starter/features/sample/data/sample_api.dart';
import 'package:suska_starter/features/sample/data/sample_models.dart';

class _MockSampleApi extends Mock implements SampleApi {}

const _pending = SampleItem(
  id: '1',
  title: 'A',
  category: 'Sarana',
  status: SampleStatus.pending,
  startDate: '2026-08-01',
  endDate: '2026-08-02',
);
const _approved = SampleItem(
  id: '2',
  title: 'B',
  category: 'Sarana',
  status: SampleStatus.approved,
  startDate: '2026-08-03',
  endDate: '2026-08-04',
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      SampleDraft(
        title: '',
        category: '',
        startDate: DateTime(2026),
        endDate: DateTime(2026),
      ),
    );
  });

  group('SampleCubit', () {
    late _MockSampleApi api;

    setUp(() {
      api = _MockSampleApi();
      when(() => api.changes).thenAnswer((_) => const Stream.empty());
    });

    test('load sukses -> ready + data + tersimpan di cache', () async {
      when(() => api.list()).thenAnswer((_) async => [_pending, _approved]);

      final cubit = SampleCubit(api: api);
      await cubit.load();

      expect(cubit.state.load, SampleLoad.ready);
      expect(cubit.state.items, [_pending, _approved]);
      expect(
        MemoryCache.get<List<SampleItem>>(SampleCubit.cacheKey),
        [_pending, _approved],
      );
    });

    test('ada cache -> tampil dulu, lalu diganti data baru', () async {
      MemoryCache.set(SampleCubit.cacheKey, [_pending]);
      when(() => api.list()).thenAnswer((_) async => [_approved]);

      final cubit = SampleCubit(api: api);
      final seen = <List<SampleItem>>[];
      final sub = cubit.stream.listen((s) => seen.add(s.items));

      await cubit.load();
      await pumpEventQueue();
      await sub.cancel();

      expect(seen, [
        [_pending],
        [_approved],
      ]);
    });

    test('load gagal tanpa data -> error dengan pesan backend', () async {
      when(() => api.list())
          .thenThrow(const ApiException('Server sedang sibuk'));

      final cubit = SampleCubit(api: api);
      await cubit.load();

      expect(cubit.state.load, SampleLoad.error);
      expect(cubit.state.errorMessage, 'Server sedang sibuk');
    });

    test('penyegaran gagal saat data sudah tampil -> data dipertahankan',
        () async {
      when(() => api.list()).thenAnswer((_) async => [_pending]);
      final cubit = SampleCubit(api: api);
      await cubit.load();

      when(() => api.list()).thenThrow(const ApiException('putus'));
      await cubit.load();

      expect(cubit.state.load, SampleLoad.ready);
      expect(cubit.state.items, [_pending]);
    });

    test('filter memilih item sesuai status', () async {
      when(() => api.list()).thenAnswer((_) async => [_pending, _approved]);
      final cubit = SampleCubit(api: api);
      await cubit.load();

      expect(cubit.state.visible, [_pending, _approved]);
      cubit.setFilter(2); // Disetujui
      expect(cubit.state.visible, [_approved]);
      cubit.setFilter(3); // Ditolak
      expect(cubit.state.visible, isEmpty);
    });

    test('data berubah (formulir terkirim) -> daftar memuat ulang',
        () async {
      // API asli (data di memori) supaya `changes` benar-benar memancar.
      final real = SampleApi(seed: const [], delay: Duration.zero);
      final cubit = SampleCubit(api: real);
      await cubit.load();
      expect(cubit.state.items, isEmpty);

      await real.create(
        SampleDraft(
          title: 'Baru',
          category: 'Sarana',
          startDate: DateTime(2026, 9),
          endDate: DateTime(2026, 9, 2),
        ),
      );
      await pumpEventQueue();

      expect(cubit.state.items.single.title, 'Baru');
      expect(cubit.state.items.single.status, SampleStatus.pending);
      await cubit.close();
    });
  });

  group('SampleFormCubit', () {
    late _MockSampleApi api;

    setUp(() => api = _MockSampleApi());

    SampleFormCubit filled() => SampleFormCubit(api: api)
      ..setTitle('  Judul  ')
      ..setCategory('Sarana')
      ..setStartDate(DateTime(2026, 9, 2))
      ..setEndDate(DateTime(2026, 9, 3));

    test('formulir kosong -> pesan validasi, API tidak dipanggil', () async {
      final cubit = SampleFormCubit(api: api);

      expect(await cubit.submit(), isFalse);
      expect(cubit.state.errorMessage, 'Judul wajib diisi');
      verifyNever(() => api.create(any()));
    });

    test('tanggal selesai sebelum mulai -> ditolak', () async {
      final cubit = filled()..setEndDate(DateTime(2026, 9));

      expect(await cubit.submit(), isFalse);
      expect(
        cubit.state.errorMessage,
        'Tanggal selesai tidak boleh sebelum tanggal mulai',
      );
    });

    test('sah -> terkirim dengan judul yang sudah dirapikan', () async {
      when(() => api.create(any())).thenAnswer((_) async => _pending);
      final cubit = filled();

      expect(await cubit.submit(), isTrue);
      expect(cubit.state.submitted, isTrue);
      final draft =
          verify(() => api.create(captureAny())).captured.single as SampleDraft;
      expect(draft.title, 'Judul');
      expect(draft.category, 'Sarana');
    });

    test('backend menolak -> pesan backend, belum terkirim', () async {
      when(() => api.create(any()))
          .thenThrow(const ApiException('Kuota habis'));
      final cubit = filled();

      expect(await cubit.submit(), isFalse);
      expect(cubit.state.submitted, isFalse);
      expect(cubit.state.submitting, isFalse);
      expect(cubit.state.errorMessage, 'Kuota habis');
    });
  });
}
