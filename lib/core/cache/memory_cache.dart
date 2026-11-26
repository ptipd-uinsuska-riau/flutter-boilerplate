/// Cache in-memory sederhana (per sesi aplikasi).
///
/// Layar membuat cubit-nya ulang tiap kali dibuka, jadi state cubit hilang saat
/// navigasi. Cache ini bertahan lintas navigasi sehingga layar dapat
/// menampilkan data terakhir SEGERA (tanpa spinner) sambil menyegarkan di
/// belakang (pola stale-while-revalidate).
///
/// Wajib di-[clear] saat logout agar data user lama tak bocor ke user baru.
abstract final class MemoryCache {
  static final Map<String, Object?> _store = <String, Object?>{};

  /// Nilai ter-cache untuk [key], atau `null` bila belum ada / tipe beda.
  static T? get<T>(String key) {
    final v = _store[key];
    return v is T ? v : null;
  }

  static void set(String key, Object? value) => _store[key] = value;

  static void remove(String key) => _store.remove(key);

  /// Hapus semua (panggil saat logout).
  static void clear() => _store.clear();
}
