/// Foto dari SSOT bisa berupa ID file Google Drive (bukan URL) — jadikan
/// URL yang bisa dimuat. `null` bila foto tidak ada.
String? resolveFotoUrl(String? foto) {
  if (foto == null || foto.isEmpty) return null;
  return foto.startsWith('http')
      ? foto
      : 'https://drive.google.com/uc?export=view&id=$foto';
}
