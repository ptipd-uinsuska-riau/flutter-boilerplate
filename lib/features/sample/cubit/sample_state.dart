part of 'sample_cubit.dart';

enum SampleLoad { loading, ready, error }

final class SampleState extends Equatable {
  const SampleState({
    this.load = SampleLoad.loading,
    this.items = const [],
    this.filter = 0,
    this.errorMessage,
  });

  /// Label chip filter; indeks 0 = semua, sisanya mengikuti
  /// [SampleStatus.values].
  static const filters = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'];

  final SampleLoad load;
  final List<SampleItem> items;
  final int filter;
  final String? errorMessage;

  /// Item sesuai chip filter yang dipilih.
  List<SampleItem> get visible => filter == 0
      ? items
      : items
          .where((i) => i.status == SampleStatus.values[filter - 1])
          .toList();

  SampleState copyWith({
    SampleLoad? load,
    List<SampleItem>? items,
    int? filter,
    String? errorMessage,
  }) =>
      SampleState(
        load: load ?? this.load,
        items: items ?? this.items,
        filter: filter ?? this.filter,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [load, items, filter, errorMessage];
}
