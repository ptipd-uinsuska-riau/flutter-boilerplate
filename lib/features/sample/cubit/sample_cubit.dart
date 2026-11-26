import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:suska_starter/core/api/api_envelope.dart';
import 'package:suska_starter/core/cache/memory_cache.dart';
import 'package:suska_starter/features/sample/data/sample_api.dart';
import 'package:suska_starter/features/sample/data/sample_models.dart';

part 'sample_state.dart';

/// Daftar pengajuan contoh — pola cache-first:
/// tampilkan data terakhir dari [MemoryCache] SEGERA (tanpa spinner), lalu
/// segarkan dari API di belakang.
class SampleCubit extends Cubit<SampleState> {
  SampleCubit({required this._api}) : super(const SampleState()) {
    _sub = _api.changes.listen((_) => unawaited(load()));
  }

  static const cacheKey = 'sample.list';

  final SampleApi _api;
  late final StreamSubscription<void> _sub;

  Future<void> load() async {
    final cached = MemoryCache.get<List<SampleItem>>(cacheKey);
    if (cached != null && state.load != SampleLoad.ready) {
      emit(state.copyWith(load: SampleLoad.ready, items: cached));
    }
    try {
      final items = await _api.list();
      if (isClosed) return;
      MemoryCache.set(cacheKey, items);
      emit(state.copyWith(load: SampleLoad.ready, items: items));
    } on Exception catch (e) {
      if (isClosed) return;
      // Sudah ada data di layar → biarkan; jangan ganti dengan layar galat.
      if (state.load == SampleLoad.ready) return;
      emit(
        state.copyWith(
          load: SampleLoad.error,
          errorMessage: apiErrorMessage(e, fallback: 'Gagal memuat data'),
        ),
      );
    }
  }

  /// Dipakai tombol "Coba Lagi" — kembali ke spinner dulu.
  Future<void> retry() async {
    emit(state.copyWith(load: SampleLoad.loading));
    await load();
  }

  void setFilter(int index) => emit(state.copyWith(filter: index));

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
