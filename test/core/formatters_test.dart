import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/core/utils/formatters.dart';

void main() {
  group('formatTime', () {
    test('null -> "----"', () => expect(formatTime(null), '----'));

    test('DateTime -> HH:mm:ss', () {
      expect(formatTime(DateTime(2026, 1, 1, 7, 5, 9)), '07:05:09');
    });

    test('string jam backend dikembalikan apa adanya', () {
      expect(formatTime('07:31'), '07:31');
      expect(formatTime('07:31:05'), '07:31:05');
    });

    test('string tidak valid -> "----"', () {
      expect(formatTime('bukan-waktu'), '----');
    });
  });

  group('formatCurrency', () {
    test('null -> "Rp. -"', () => expect(formatCurrency(null), 'Rp. -'));

    test('format pemisah ribuan id-ID', () {
      expect(formatCurrency(1500000), 'Rp. 1.500.000');
    });
  });

  group('greetingForHour', () {
    test('pagi/siang/malam', () {
      expect(greetingForHour(8), 'Selamat Pagi!');
      expect(greetingForHour(13), 'Selamat Siang!');
      expect(greetingForHour(20), 'Selamat Malam!');
    });
  });

  group('formatPercent', () {
    test('bulat -> tanpa desimal', () {
      expect(formatPercent(0), '0%');
      expect(formatPercent(5), '5%');
      expect(formatPercent(12.0), '12%');
    });

    test('pecahan -> koma desimal Indonesia, maks 2 angka', () {
      expect(formatPercent(2.5), '2,5%');
      expect(formatPercent(1.256), '1,26%');
      expect(formatPercent(3.10), '3,1%');
    });

    test('null -> "-" (data belum tersedia)', () {
      expect(formatPercent(null), '-');
    });
  });
}
