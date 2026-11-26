import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ikon aplikasi & layar pembuka harus logo aplikasi (dipasang lewat
/// `tool/branding/apply_icons.sh`), bukan gambar bawaan Very Good CLI
/// (unicorn) — di Presensia gambar itu sempat ikut terbit sampai rilis 4.
///
/// Test ini tak bisa "melihat" gambar; yang dijaga adalah susunan berkasnya:
/// vektor bawaan template tidak kembali, dan setiap berkas yang dirujuk
/// benar-benar ada (rujukan yang hilang menggagalkan build Android).
void main() {
  const res = 'android/app/src/main/res';
  const densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

  /// Awal path vektor unicorn bawaan template.
  const templatePath = 'M809.52,353.5C784.41,314.52';

  group('Android', () {
    test('vektor bawaan template sudah dibuang', () {
      expect(
        File('$res/drawable/ic_launcher_foreground.xml').existsSync(),
        isFalse,
      );
      expect(File('$res/drawable/ic_launch_image.xml').existsSync(), isFalse);

      final leftovers = Directory('android/app/src')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.xml'))
          .where((f) => f.readAsStringSync().contains(templatePath))
          .map((f) => f.path)
          .toList();
      expect(leftovers, isEmpty);
    });

    test('ikon adaptif merujuk latar depan PNG yang tersedia', () {
      for (final name in ['ic_launcher', 'ic_launcher_round']) {
        final xml =
            File('$res/mipmap-anydpi-v26/$name.xml').readAsStringSync();
        expect(xml, contains('@mipmap/ic_launcher_foreground'), reason: name);
        expect(xml, contains('@color/ic_launcher_background'), reason: name);
      }
      expect(
        File('$res/values/ic_launcher_background.xml').readAsStringSync(),
        contains('name="ic_launcher_background"'),
      );
    });

    test('setiap kerapatan layar punya ikon dan gambar pembuka', () {
      for (final density in densities) {
        for (final path in [
          '$res/mipmap-$density/ic_launcher.png',
          '$res/mipmap-$density/ic_launcher_round.png',
          '$res/mipmap-$density/ic_launcher_foreground.png',
          '$res/drawable-$density/ic_launch_image.png',
        ]) {
          expect(File(path).existsSync(), isTrue, reason: path);
        }
      }
    });

    test('layar pembuka merujuk gambar pembuka', () {
      for (final dir in ['drawable', 'drawable-v21']) {
        expect(
          File('$res/$dir/launch_background.xml').readAsStringSync(),
          contains('@drawable/ic_launch_image'),
          reason: dir,
        );
      }
    });

    test('flavor tidak menimpa ikon dengan versi lama', () {
      for (final flavor in ['development', 'staging', 'production']) {
        final dir = Directory('android/app/src/$flavor');
        final icons = dir.existsSync()
            ? dir
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.contains('ic_launch'))
                .map((f) => f.path)
                .toList()
            : const <String>[];
        expect(icons, isEmpty, reason: flavor);
      }
    });
  });

  group('iOS', () {
    test('ikon aplikasi memakai Logo.png, bukan Logo.svg bawaan template',
        () {
      for (final icon in ['AppIcon', 'AppIcon-dev', 'AppIcon-stg']) {
        final dir = 'ios/Runner/AppIcons/$icon.icon';
        expect(File('$dir/Assets/Logo.png').existsSync(), isTrue, reason: dir);
        expect(File('$dir/Assets/Logo.svg').existsSync(), isFalse, reason: dir);

        final json = File('$dir/icon.json').readAsStringSync();
        expect(json, contains('"image-name" : "Logo.png"'), reason: dir);
        expect(json, isNot(contains('Logo.svg')), reason: dir);
      }
    });

    test('gambar layar pembuka tersedia di tiga skala', () {
      for (final suffix in ['@1x', '@2x', '@3x']) {
        final path = 'ios/Runner/Assets.xcassets/LaunchImage.imageset/'
            'LaunchImage$suffix.png';
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    });
  });
}
