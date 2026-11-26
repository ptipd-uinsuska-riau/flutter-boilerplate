import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suska_starter/core/format/dates.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  group('formatIsoDate', () {
    test('ISO dengan Z -> "20 Agu 2026" (tanpa geser hari)', () {
      expect(formatIsoDate('2026-08-20T00:00:00Z'), '20 Agu 2026');
    });

    test('tanggal-only -> "20 Agu 2026"', () {
      expect(formatIsoDate('2026-08-20'), '20 Agu 2026');
    });

    test('tak bisa di-parse -> dikembalikan apa adanya', () {
      expect(formatIsoDate('bukan-tanggal'), 'bukan-tanggal');
    });
  });

  test('formatIsoRange -> "20 Agu 2026 s/d 21 Agu 2026"', () {
    expect(
      formatIsoRange('2026-08-20T00:00:00Z', '2026-08-21T00:00:00Z'),
      '20 Agu 2026 s/d 21 Agu 2026',
    );
  });
}
