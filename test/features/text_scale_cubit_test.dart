import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suska_starter/core/settings/text_scale_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default 1.0 sebelum load', () {
    SharedPreferences.setMockInitialValues({});
    expect(TextScaleCubit().state, 1.0);
  });

  test('load membaca skala tersimpan', () async {
    SharedPreferences.setMockInitialValues({TextScaleCubit.prefsKey: 1.3});
    final cubit = TextScaleCubit();
    await cubit.load();
    expect(cubit.state, 1.3);
  });

  test('load menjepit nilai liar ke rentang aman', () async {
    SharedPreferences.setMockInitialValues({TextScaleCubit.prefsKey: 9.0});
    final cubit = TextScaleCubit();
    await cubit.load();
    expect(cubit.state, TextScaleCubit.maxScale);
  });

  test('setScale emit + persist', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = TextScaleCubit();
    await cubit.setScale(1.15);
    expect(cubit.state, 1.15);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble(TextScaleCubit.prefsKey), 1.15);
  });

  test('opsi bawaan: Normal/Besar/Sangat Besar dalam rentang teruji', () {
    expect(TextScaleCubit.options, hasLength(3));
    for (final (_, value) in TextScaleCubit.options) {
      expect(value, inInclusiveRange(1.0, TextScaleCubit.maxScale));
    }
  });
}
