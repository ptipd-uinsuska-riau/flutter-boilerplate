import 'package:equatable/equatable.dart';

/// Status pengajuan contoh. Nilai tak dikenal dari server jatuh ke
/// [pending] — server tidak boleh bisa membuat aplikasi crash.
enum SampleStatus {
  pending('Menunggu'),
  approved('Disetujui'),
  rejected('Ditolak');

  const SampleStatus(this.label);

  final String label;

  static SampleStatus parse(Object? raw) {
    final value = raw is String ? raw.trim().toLowerCase() : '';
    return SampleStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => SampleStatus.pending,
    );
  }
}

/// Satu pengajuan contoh.
///
/// POLA WAJIB untuk semua model: `fromJson` DEFENSIF — setiap field punya
/// nilai cadangan dan tidak ada `as` terhadap data server yang bisa
/// melempar `TypeError`.
final class SampleItem extends Equatable {
  const SampleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.note = '',
  });

  factory SampleItem.fromJson(Map<String, dynamic> json) => SampleItem(
        // Backend kadang mengirim id sebagai angka, kadang string.
        id: '${json['id'] ?? ''}',
        title: _str(json['title']),
        category: _str(json['category']),
        status: SampleStatus.parse(json['status']),
        startDate: _str(json['start_date']),
        endDate: _str(json['end_date']),
        note: _str(json['note']),
      );

  static String _str(Object? value) => value is String ? value : '';

  final String id;
  final String title;
  final String category;
  final SampleStatus status;

  /// Tanggal ISO (`2026-08-20`) — diformat di layar dengan `formatIsoDate`.
  final String startDate;
  final String endDate;
  final String note;

  @override
  List<Object?> get props =>
      [id, title, category, status, startDate, endDate, note];
}

/// Isi formulir pengajuan baru.
final class SampleDraft extends Equatable {
  const SampleDraft({
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.note = '',
  });

  final String title;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String note;

  /// Bentuk yang dikirim ke backend.
  Map<String, dynamic> toJson() => {
        'title': title,
        'category': category,
        'start_date': _isoDate(startDate),
        'end_date': _isoDate(endDate),
        'note': note,
      };

  static String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [title, category, startDate, endDate, note];
}
