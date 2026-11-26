// Mengganti identitas kerangka ini menjadi aplikasi baru.
//
//   dart run tool/rename.dart \
//     --name ppid_mobile \
//     --app-id id.ac.uinsuska.ppid \
//     --title "PPID UIN Suska"
//
// Yang diganti: nama paket Dart (pubspec + semua import), applicationId &
// namespace Android (termasuk folder Kotlin `MainActivity`), bundle id iOS,
// nama yang tampil di bawah ikon (Android & iOS), `AppConfig.appName`, dan
// `AppConfig.storeUrl`.
//
// Nilai LAMA dibaca dari berkas proyek, bukan ditulis mati di sini, jadi
// alat ini boleh dijalankan lagi kapan pun identitas perlu diubah.
//
// Skrip CLI: keluaran ke terminal memang lewat `stdout`/`stderr`.
import 'dart:io';

const _pubspec = 'pubspec.yaml';
const _gradle = 'android/app/build.gradle.kts';
const _kotlinRoot = 'android/app/src/main/kotlin';
const _pbxproj = 'ios/Runner.xcodeproj/project.pbxproj';
const _appConfig = 'lib/core/config/app_config.dart';

void main(List<String> args) {
  final options = _parse(args);
  final name = options['name'];
  final appId = options['app-id'];
  final title = options['title'];

  if (name == null || appId == null || title == null) {
    _fail(
      'Pemakaian:\n'
      '  dart run tool/rename.dart --name <paket_dart> '
      '--app-id <id.aplikasi> --title "<Nama Aplikasi>"',
    );
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    _fail('--name harus snake_case (huruf kecil, angka, _): "$name"');
  }
  // Tanpa "_" (ditolak iOS) dan tanpa "-" (ditolak Android).
  if (!RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch(appId)) {
    _fail(
      '--app-id harus berbentuk id.ac.contoh.aplikasi (huruf kecil dan '
      'angka, dipisah titik): "$appId"',
    );
  }
  if (title.trim().isEmpty || RegExp(r'''["'\\$]''').hasMatch(title)) {
    _fail(r'--title tidak boleh kosong atau berisi tanda kutip, \ atau $');
  }
  for (final path in [_pubspec, _gradle, _pbxproj, _appConfig]) {
    if (!File(path).existsSync()) {
      _fail('$path tidak ditemukan — jalankan dari folder akar proyek.');
    }
  }

  final oldName = _capture(_pubspec, RegExp(r'^name:\s*(\S+)\s*$', multiLine: true));
  final oldAppId = _capture(_gradle, RegExp(r'applicationId\s*=\s*"([^"]+)"'));
  final oldTitle = _capture(
    _appConfig,
    RegExp("static const appName = '([^']*)';"),
  );

  stdout
    ..writeln('Paket Dart : $oldName -> $name')
    ..writeln('ID aplikasi: $oldAppId -> $appId')
    ..writeln('Nama tampil: $oldTitle -> $title');

  // 1. Paket Dart: pubspec + semua import.
  _edit(
    _pubspec,
    (s) => s.replaceFirst(
      RegExp(r'^name:\s*\S+\s*$', multiLine: true),
      'name: $name',
    ),
  );
  var dartFiles = 0;
  for (final dir in ['lib', 'test', 'tool']) {
    final root = Directory(dir);
    if (!root.existsSync()) continue;
    for (final file in root.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final before = file.readAsStringSync();
      final after = before.replaceAll('package:$oldName/', 'package:$name/');
      if (after != before) {
        file.writeAsStringSync(after);
        dartFiles++;
      }
    }
  }
  stdout.writeln('Import diperbarui di $dartFiles berkas Dart.');

  // 2. Android: applicationId, namespace, nama tampil, folder Kotlin.
  _edit(
    _gradle,
    (s) => s
        .replaceAll('"$oldAppId"', '"$appId"')
        .replaceAll('$oldTitle"', '$title"'),
  );
  _moveMainActivity(oldAppId, appId);

  // 3. iOS: bundle id (termasuk `.RunnerTests`) dan nama tampil per flavor.
  _edit(_pbxproj, (s) {
    final lines = s.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('PRODUCT_BUNDLE_IDENTIFIER')) {
        lines[i] = line.replaceAll(oldAppId, appId);
      } else if (line.contains('FLAVOR_APP_NAME')) {
        lines[i] = line.replaceAll(oldTitle, title);
      }
    }
    return lines.join('\n');
  });

  // 4. Konfigurasi aplikasi.
  _edit(
    _appConfig,
    (s) => s
        .replaceFirst(
          RegExp("static const appName = '[^']*';"),
          "static const appName = '$title';",
        )
        .replaceFirst(
          RegExp(r"static const storeUrl =\s*'[^']*';"),
          'static const storeUrl =\n'
              "      'https://play.google.com/store/apps/details?id=$appId';",
        ),
  );

  // 5. Nama paket baru mengubah urutan abjad import → rapikan supaya
  //    `flutter analyze` tetap bersih.
  final fix = Process.runSync(
    Platform.resolvedExecutable,
    ['fix', '--apply', '--code=directives_ordering'],
  );
  if (fix.exitCode != 0) {
    stderr.writeln(
      'Peringatan: "dart fix" gagal — jalankan sendiri: '
      'dart fix --apply --code=directives_ordering\n${fix.stderr}',
    );
  }

  stdout.writeln('''

Selesai. Yang masih HARUS diisi tangan (cari "GANTI" di proyek):
  1. lib/core/config/app_config.dart  : apiUrl, appId (katalog SSOT),
                                        appTagline
  2. ios/Runner/Info.plist            : GIDClientID + URL scheme (iOS client)
  3. Google Cloud Console             : OAuth Android client untuk
                                        $appId + SHA-1 (debug & rilis)
  4. Halaman Syarat & Ketentuan dan Kebijakan Privasi (masih kerangka)
  5. Ikon: sh tool/branding/apply_icons.sh <logo.png>

Lalu:  flutter pub get && flutter analyze && flutter test''');
}

Map<String, String> _parse(List<String> args) {
  final out = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (!arg.startsWith('--')) _fail('Argumen tak dikenal: $arg');
    final eq = arg.indexOf('=');
    if (eq > 0) {
      out[arg.substring(2, eq)] = arg.substring(eq + 1);
    } else if (i + 1 < args.length) {
      out[arg.substring(2)] = args[++i];
    } else {
      _fail('Nilai untuk $arg tidak ada.');
    }
  }
  return out;
}

String _capture(String path, RegExp pattern) {
  final match = pattern.firstMatch(File(path).readAsStringSync());
  if (match == null) _fail('Pola ${pattern.pattern} tidak ditemukan di $path');
  return match.group(1)!;
}

void _edit(String path, String Function(String) change) {
  final file = File(path);
  final before = file.readAsStringSync();
  final after = change(before);
  if (after != before) file.writeAsStringSync(after);
}

/// Folder Kotlin harus mengikuti nama paket: `id.ac.x` → `id/ac/x/`.
void _moveMainActivity(String oldAppId, String newAppId) {
  if (oldAppId == newAppId) return;
  final oldDir = Directory('$_kotlinRoot/${oldAppId.replaceAll('.', '/')}');
  final oldFile = File('${oldDir.path}/MainActivity.kt');
  if (!oldFile.existsSync()) {
    _fail('${oldFile.path} tidak ditemukan — folder Kotlin tidak cocok '
        'dengan applicationId "$oldAppId".');
  }
  final source = oldFile
      .readAsStringSync()
      .replaceFirst('package $oldAppId', 'package $newAppId');
  final newDir = Directory('$_kotlinRoot/${newAppId.replaceAll('.', '/')}')
    ..createSync(recursive: true);
  File('${newDir.path}/MainActivity.kt').writeAsStringSync(source);
  oldFile.deleteSync();

  // Buang folder lama yang kini kosong, dari yang terdalam ke atas.
  var dir = oldDir;
  while (dir.path != _kotlinRoot &&
      dir.existsSync() &&
      dir.listSync().isEmpty) {
    dir.deleteSync();
    dir = dir.parent;
  }
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
