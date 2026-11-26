part of 'sample_form_cubit.dart';

final class SampleFormState extends Equatable {
  const SampleFormState({
    this.title = '',
    this.category,
    this.startDate,
    this.endDate,
    this.note = '',
    this.submitting = false,
    this.submitted = false,
    this.errorMessage,
  });

  /// Pilihan dropdown "Kategori".
  static const categories = ['Sarana', 'Layanan TI', 'Kepegawaian'];

  final String title;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final String note;
  final bool submitting;
  final bool submitted;
  final String? errorMessage;

  /// Pesan validasi pertama yang gagal, `null` bila formulir sah.
  String? get validationError {
    if (title.trim().isEmpty) return 'Judul wajib diisi';
    if (category == null) return 'Kategori wajib dipilih';
    final start = startDate;
    final end = endDate;
    if (start == null || end == null) return 'Tanggal wajib diisi';
    if (end.isBefore(start)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai';
    }
    return null;
  }

  SampleFormState copyWith({
    String? title,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? note,
    bool? submitting,
    bool? submitted,
    String? errorMessage,
  }) =>
      SampleFormState(
        title: title ?? this.title,
        category: category ?? this.category,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        note: note ?? this.note,
        submitting: submitting ?? this.submitting,
        submitted: submitted ?? this.submitted,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        title,
        category,
        startDate,
        endDate,
        note,
        submitting,
        submitted,
        errorMessage,
      ];
}
