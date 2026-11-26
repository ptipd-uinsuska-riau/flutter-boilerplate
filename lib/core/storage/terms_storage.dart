import 'package:shared_preferences/shared_preferences.dart';

/// Persetujuan Syarat & Ketentuan (tersimpan di perangkat).
class TermsStorage {
  static const _key = 'terms_accepted';

  Future<bool> hasAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
