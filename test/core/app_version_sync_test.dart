import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/core/config/app_config.dart';

/// `AppConfig.appVersion` dipakai cek pembaruan dan dikirim di header
/// `X-App-Version` — WAJIB sama dengan nama versi di pubspec (tanpa `+kode`).
void main() {
  test('AppConfig.appVersion + appBuild sinkron dengan version di pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(match, isNotNull, reason: 'baris version: x.y.z+kode tak ada');
    expect(AppConfig.appVersion, match!.group(1));
    // Kode versi = versionCode Android / CFBundleVersion iOS; dipakai
    // membandingkan build terpasang dengan `latest_build` backend.
    expect(AppConfig.appBuild, int.parse(match.group(2)!));
  });
}
