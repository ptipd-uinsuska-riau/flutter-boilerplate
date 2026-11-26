import 'package:intl/intl.dart';

/// Format tanggal ISO-8601 (`2026-08-20T00:00:00Z` atau `2026-08-20`) menjadi
/// `"20 Agu 2026"`. Kembalikan string asal bila tak bisa di-parse.
///
/// Sengaja TIDAK memakai `toLocal()` agar tanggal-only `T00:00:00Z` tidak
/// bergeser mundur satu hari pada device di zona waktu negatif.
String formatIsoDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return DateFormat('dd MMM yyyy', 'id_ID').format(d);
}

/// `"20 Agu 2026 s/d 21 Agu 2026"` dari dua ISO date.
String formatIsoRange(String startIso, String endIso) =>
    '${formatIsoDate(startIso)} s/d ${formatIsoDate(endIso)}';
