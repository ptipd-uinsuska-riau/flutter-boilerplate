import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Penjaga kerangka: (1) jangkar yang dibaca `tool/rename.dart` masih ada
/// dan saling cocok, (2) tidak ada kunci/ID milik aplikasi lain yang ikut
/// ter-commit.
void main() {
  String read(String path) => File(path).readAsStringSync();

  group('jangkar tool/rename.dart', () {
    late String appId;

    setUpAll(() {
      final match = RegExp(r'applicationId\s*=\s*"([^"]+)"')
          .firstMatch(read('android/app/build.gradle.kts'));
      expect(match, isNotNull, reason: 'applicationId tak ditemukan');
      appId = match!.group(1)!;
    });

    test('pubspec punya baris name:', () {
      expect(
        RegExp(r'^name:\s*[a-z][a-z0-9_]*\s*$', multiLine: true)
            .hasMatch(read('pubspec.yaml')),
        isTrue,
      );
    });

    test('namespace Android = applicationId', () {
      expect(
        read('android/app/build.gradle.kts'),
        contains('namespace = "$appId"'),
      );
    });

    test('MainActivity berada di folder & paket yang sesuai applicationId',
        () {
      final file = File(
        'android/app/src/main/kotlin/${appId.replaceAll('.', '/')}'
        '/MainActivity.kt',
      );
      expect(file.existsSync(), isTrue, reason: file.path);
      expect(file.readAsStringSync(), contains('package $appId'));
    });

    test('bundle id iOS = applicationId Android', () {
      expect(
        read('ios/Runner.xcodeproj/project.pbxproj'),
        contains('PRODUCT_BUNDLE_IDENTIFIER = $appId;'),
      );
    });

    test('AppConfig punya appName dan storeUrl yang bisa diganti', () {
      final config = read('lib/core/config/app_config.dart');
      expect(
        RegExp("static const appName = '[^']+';").hasMatch(config),
        isTrue,
      );
      expect(
        RegExp(r"static const storeUrl =\s*'[^']*';").hasMatch(config),
        isTrue,
      );
    });

    test('nama di bawah ikon sama di Android, iOS, dan AppConfig', () {
      final name = RegExp("static const appName = '([^']+)';")
          .firstMatch(read('lib/core/config/app_config.dart'))!
          .group(1)!;
      expect(
        read('android/app/build.gradle.kts'),
        contains('manifestPlaceholders["appName"] = "$name"'),
      );
      expect(
        read('ios/Runner.xcodeproj/project.pbxproj'),
        contains('FLAVOR_APP_NAME = "$name";'),
      );
    });
  });

  group('tidak ada rahasia yang ikut ter-commit', () {
    /// Berkas teks yang dilacak (tanpa hasil build dan dependensi).
    Iterable<File> sources() sync* {
      const roots = ['lib', 'test', 'tool', 'docs', 'android', 'ios'];
      const skipped = [
        '/build/',
        '/.gradle/',
        '/Pods/',
        '/.symlinks/',
        '/ephemeral/',
        'local.properties',
      ];
      const textual = [
        '.dart',
        '.kts',
        '.kt',
        '.xml',
        '.plist',
        '.swift',
        '.md',
        '.yaml',
        '.json',
        '.properties',
        '.pbxproj',
        '.xcconfig',
      ];
      for (final root in roots) {
        final dir = Directory(root);
        if (!dir.existsSync()) continue;
        for (final file in dir.listSync(recursive: true).whereType<File>()) {
          final path = file.path;
          if (skipped.any(path.contains)) continue;
          if (!textual.any(path.endsWith)) continue;
          // Berkas ini sendiri memuat pola yang dicari.
          if (path.endsWith('template_guard_test.dart')) continue;
          yield file;
        }
      }
    }

    test('tak ada kunci API Google (AIza…)', () {
      final hits = sources()
          .where((f) => RegExp('AIza[0-9A-Za-z_-]{20,}')
              .hasMatch(f.readAsStringSync()))
          .map((f) => f.path)
          .toList();
      expect(hits, isEmpty);
    });

    test('tak ada kunci privat atau kata sandi keystore rilis', () {
      final hits = sources()
          .where((f) {
            final s = f.readAsStringSync();
            return s.contains('BEGIN PRIVATE KEY') ||
                s.contains('BEGIN RSA PRIVATE KEY');
          })
          .map((f) => f.path)
          .toList();
      expect(hits, isEmpty);
      for (final path in [
        'android/key.properties',
        'android/app/google-services.json',
        'ios/Runner/GoogleService-Info.plist',
      ]) {
        final tracked = Process.runSync('git', ['ls-files', '--', path]);
        expect(
          (tracked.stdout as String).trim(),
          isEmpty,
          reason: '$path tidak boleh dilacak git',
        );
      }
    });
  });
}
