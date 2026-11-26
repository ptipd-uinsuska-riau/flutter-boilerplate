// Helper format murni (tanpa Flutter) — mudah diuji unit.
import 'package:intl/intl.dart';

/// Format ISO string/`DateTime` ke `HH:mm:ss`. `"----"` bila kosong/invalid.
///
/// String yang sudah berbentuk jam (`07:31` / `07:31:05`)
/// dikembalikan apa adanya alih-alih gagal parse menjadi `"----"`.
String formatTime(Object? dateOrString) {
  if (dateOrString == null) return '----';

  if (dateOrString is DateTime) return _hms(dateOrString);

  final raw = dateOrString.toString();
  if (raw.isEmpty) return '----';

  final parsed = DateTime.tryParse(raw);
  if (parsed != null) return _hms(parsed.toLocal());

  // Sudah berupa jam "HH:mm" / "HH:mm:ss" dari backend.
  if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(raw)) return raw;

  return '----';
}

String _hms(DateTime d) =>
    '${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}';

String _two(int n) => n.toString().padLeft(2, '0');

/// Format Rupiah `Rp. 1.234.567`. `"Rp. -"` bila null.
String formatCurrency(num? amount) {
  if (amount == null) return 'Rp. -';
  return 'Rp. ${NumberFormat.decimalPattern('id_ID').format(amount)}';
}

/// Angka ribuan gaya Indonesia tanpa simbol: `1.234.567` (dibulatkan).
String formatAmount(num amount) =>
    NumberFormat.decimalPattern('id_ID').format(amount.round());

/// Format persen gaya Indonesia: `5%`, `2,5%` (maks 2 desimal).
/// `"-"` bila null (data belum tersedia).
String formatPercent(num? value) {
  if (value == null) return '-';
  return '${NumberFormat('0.##', 'id_ID').format(value)}%';
}

/// Sapaan berdasarkan jam.
String greetingForHour(int hour) {
  if (hour < 12) return 'Selamat Pagi!';
  if (hour < 18) return 'Selamat Siang!';
  return 'Selamat Malam!';
}
