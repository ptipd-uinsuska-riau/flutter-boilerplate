import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Skala teks pilihan user (fitur aksesibilitas — membantu pengguna lanjut
/// usia). Nilai dikalikan dengan skala font sistem dan diterapkan lewat
/// `MediaQuery.textScaler` di akar `MaterialApp`.
///
/// Rentang dijepit ke [1.0, maxScale]; 1.3 adalah batas yang sudah
/// dibuktikan bebas overflow oleh `responsive_smoke_test.dart`.
class TextScaleCubit extends Cubit<double> {
  TextScaleCubit() : super(1);

  static const prefsKey = 'settings.text_scale';
  static const maxScale = 1.3;

  /// (label, nilai) — dipakai lembar pilihan "Ukuran Teks".
  static const options = <(String, double)>[
    ('Normal', 1.0),
    ('Besar', 1.15),
    ('Sangat Besar', 1.3),
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(prefsKey);
    if (stored != null) emit(stored.clamp(1.0, maxScale));
  }

  Future<void> setScale(double value) async {
    final clamped = value.clamp(1.0, maxScale);
    emit(clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(prefsKey, clamped);
  }
}
