import 'dart:convert';

/// Decode payload JWT tanpa verifikasi tanda tangan — hanya untuk membaca
/// klaim seperti `email`, BUKAN untuk memutuskan hak akses.
Map<String, dynamic>? decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  } on FormatException {
    return null;
  }
}
