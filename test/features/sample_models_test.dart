import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/features/sample/data/sample_models.dart';

void main() {
  group('SampleItem.fromJson', () {
    test('membaca semua field', () {
      final item = SampleItem.fromJson(const {
        'id': 7,
        'title': 'Judul',
        'category': 'Sarana',
        'status': 'approved',
        'start_date': '2026-08-20',
        'end_date': '2026-08-21',
        'note': 'catatan',
      });

      expect(item.id, '7');
      expect(item.title, 'Judul');
      expect(item.status, SampleStatus.approved);
      expect(item.startDate, '2026-08-20');
      expect(item.note, 'catatan');
    });

    test('field hilang / bertipe salah -> nilai cadangan, tidak melempar',
        () {
      final item = SampleItem.fromJson(const {
        'id': null,
        'title': 123,
        'status': {'kode': 1},
        'start_date': ['2026'],
      });

      expect(item.id, '');
      expect(item.title, '');
      expect(item.category, '');
      expect(item.status, SampleStatus.pending);
      expect(item.startDate, '');
      expect(item.endDate, '');
      expect(item.note, '');
    });

    test('status tak dikenal / beda huruf besar', () {
      expect(SampleStatus.parse('REJECTED'), SampleStatus.rejected);
      expect(SampleStatus.parse(' approved '), SampleStatus.approved);
      expect(SampleStatus.parse('dibatalkan'), SampleStatus.pending);
      expect(SampleStatus.parse(null), SampleStatus.pending);
    });
  });

  test('SampleDraft.toJson mengirim tanggal sebagai YYYY-MM-DD', () {
    final json = SampleDraft(
      title: 'Judul',
      category: 'Sarana',
      startDate: DateTime(2026, 8, 5),
      endDate: DateTime(2026, 12, 31),
    ).toJson();

    expect(json['start_date'], '2026-08-05');
    expect(json['end_date'], '2026-12-31');
    expect(json['note'], '');
  });
}
