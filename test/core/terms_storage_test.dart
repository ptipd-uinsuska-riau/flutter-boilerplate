import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suska_starter/core/storage/terms_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TermsStorage', () {
    test('default: belum menyetujui syarat', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await TermsStorage().hasAccepted(), isFalse);
    });

    test('setAccepted menyimpan persetujuan secara persisten', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = TermsStorage();

      await storage.setAccepted();

      expect(await storage.hasAccepted(), isTrue);
      // Instance baru membaca nilai yang sama (persisten).
      expect(await TermsStorage().hasAccepted(), isTrue);
    });
  });
}
