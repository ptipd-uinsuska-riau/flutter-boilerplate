import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Penjaga pengerasan AndroidManifest (laporan keamanan 2026-11-18).
///
/// Nilai-nilai ini mudah terhapus tanpa sengaja saat manifest disunting,
/// dan tak ada test lain yang akan gagal bila itu terjadi.
void main() {
  late String application;

  setUpAll(() {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final match = RegExp(r'<application\b[^>]*>').firstMatch(manifest);
    expect(match, isNotNull, reason: 'tag <application> tidak ditemukan');
    application = match!.group(0)!;
  });

  test('cadangan data aplikasi dimatikan', () {
    // Token ada di Keystore (tak ikut dicadangkan); berkas terenkripsinya
    // tak boleh ikut ke cadangan cloud/adb.
    expect(application, contains('android:allowBackup="false"'));
    // Bila ada pustaka yang mendeklarasikan allowBackup, nilai kita menang.
    expect(application, contains('tools:replace="android:allowBackup"'));
  });

  test('lalu lintas tanpa TLS ditolak secara eksplisit', () {
    expect(application, contains('android:usesCleartextTraffic="false"'));
  });
}
