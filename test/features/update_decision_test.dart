import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/features/app_version/data/app_version_api.dart';
import 'package:suska_starter/features/app_version/data/update_decision.dart';

/// Kontrak (asal: be-presensia): backend hanya membandingkan `version`;
/// build terpasang hanya diketahui aplikasi.
void main() {
  VersionCheck res({
    bool updateAvailable = false,
    bool isRequired = false,
    String latestVersion = '1.1.0',
    int? latestBuild = 4,
    int? minBuild,
  }) =>
      VersionCheck(
        updateAvailable: updateAvailable,
        isRequired: isRequired,
        latestVersion: latestVersion,
        latestBuild: latestBuild,
        minBuild: minBuild,
        releaseNotes: 'catatan',
      );

  VersionCheck? decide(
    VersionCheck check, {
    String version = '1.1.0',
    int build = 4,
  }) =>
      decideUpdate(check, installedVersion: version, installedBuild: build);

  group('data versi kosong (mis. iOS) -> tidak ada update', () {
    test('latest_version kosong', () {
      expect(decide(res(latestVersion: '', latestBuild: 0)), isNull);
      expect(
        decide(res(updateAvailable: true, latestVersion: '')),
        isNull,
      );
    });

    test('latest_build 0', () {
      expect(decide(res(updateAvailable: true, latestBuild: 0)), isNull);
    });
  });

  group('versi berbeda -> ikuti keputusan backend', () {
    test('update wajib', () {
      final check = res(updateAvailable: true, isRequired: true);
      expect(decide(check, version: '1.0.2', build: 3), check);
    });

    test('update opsional', () {
      final out = decide(res(updateAvailable: true), version: '1.0.2');
      expect(out?.updateAvailable, isTrue);
      expect(out?.isRequired, isFalse);
    });
  });

  group('versi sama -> bandingkan build', () {
    test('build terpasang lebih lama -> update OPSIONAL', () {
      final out = decide(res(), build: 3);
      expect(out, isNotNull);
      expect(out!.updateAvailable, isTrue);
      expect(out.isRequired, isFalse);
      expect(out.latestVersion, '1.1.0');
      expect(out.releaseNotes, 'catatan');
    });

    test('build lebih lama + is_required dari backend -> wajib', () {
      final out = decide(res(isRequired: true), build: 2);
      expect(out?.isRequired, isTrue);
    });

    test('build sama -> tidak ada update', () {
      expect(decide(res()), isNull);
    });

    test('build terpasang lebih baru (uji/internal) -> tidak ada update', () {
      expect(decide(res(), build: 9), isNull);
    });
  });

  test('versi terpasang berbeda & backend bilang tidak -> build diabaikan',
      () {
    // 1.1.1+5 terpasang, backend masih 1.1.0 build 9.
    expect(decide(res(latestBuild: 9), version: '1.1.1', build: 5), isNull);
  });

  group('min_build (batas build wajib dari backend)', () {
    test('build terpasang di bawah min_build -> update WAJIB', () {
      // Backend belum menandai apa pun (mis. `build` tak terbaca di sana).
      final out = decide(res(latestBuild: 6, minBuild: 6), build: 5);
      expect(out, isNotNull);
      expect(out!.updateAvailable, isTrue);
      expect(out.isRequired, isTrue);
      expect(out.releaseNotes, 'catatan');
    });

    test('berlaku juga saat versi terpasang berbeda', () {
      final out = decide(
        res(latestVersion: '1.2.0', latestBuild: 6, minBuild: 6),
        version: '1.1.1',
        build: 5,
      );
      expect(out?.isRequired, isTrue);
    });

    test('update opsional dari backend naik jadi wajib', () {
      final out = decide(
        res(updateAvailable: true, latestBuild: 6, minBuild: 6),
        build: 5,
      );
      expect(out?.isRequired, isTrue);
    });

    test('build sama dengan min_build -> tidak dipaksa', () {
      expect(decide(res(latestBuild: 5, minBuild: 5), build: 5), isNull);
      // Build lebih lama dari latest tetapi sudah >= min_build: opsional.
      final out = decide(res(latestBuild: 6, minBuild: 5), build: 5);
      expect(out?.updateAvailable, isTrue);
      expect(out?.isRequired, isFalse);
    });

    test('min_build kosong/0 -> tidak ada batas', () {
      expect(decide(res(minBuild: 0)), isNull);
      expect(decide(res()), isNull);
    });

    test('data versi kosong tetap menang atas min_build', () {
      expect(
        decide(res(latestVersion: '', latestBuild: 0, minBuild: 9)),
        isNull,
      );
    });
  });

  group('latest_build tidak dikirim (kontrak lama)', () {
    test('tetap mengikuti update_available', () {
      final check = res(updateAvailable: true, latestBuild: null);
      expect(decide(check, version: '1.0.2'), check);
    });

    test('versi sama -> tidak ada update', () {
      expect(decide(res(latestBuild: null), build: 1), isNull);
    });
  });

  group('VersionCheck.fromJson defensif', () {
    test('bentuk nyata', () {
      final check = VersionCheck.fromJson(const {
        'update_available': false,
        'is_required': false,
        'latest_version': '1.1.0',
        'latest_build': 4,
        'current_version': '1.1.0',
        'release_notes': 'catatan',
      });
      expect(check.latestVersion, '1.1.0');
      expect(check.latestBuild, 4);
      expect(check.releaseNotes, 'catatan');
      expect(check.downloadUrl, isNull);
    });

    test('tipe tak terduga tidak melempar', () {
      final check = VersionCheck.fromJson(const {
        'update_available': 'ya',
        'is_required': 1,
        'latest_version': 110,
        'latest_build': '4',
        'download_url': 5,
        'release_notes': ['a'],
      });
      expect(check.updateAvailable, isFalse);
      expect(check.isRequired, isFalse);
      expect(check.latestVersion, '');
      expect(check.latestBuild, 4);
      expect(check.downloadUrl, isNull);
      expect(check.releaseNotes, isNull);
    });

    test('min_build: angka, string angka, atau tipe lain', () {
      expect(VersionCheck.fromJson(const {'min_build': 5}).minBuild, 5);
      expect(VersionCheck.fromJson(const {'min_build': '5'}).minBuild, 5);
      expect(VersionCheck.fromJson(const {'min_build': null}).minBuild, isNull);
      expect(VersionCheck.fromJson(const {'min_build': [5]}).minBuild, isNull);
      expect(VersionCheck.fromJson(const {}).minBuild, isNull);
    });

    test('latest_build pecahan/kosong', () {
      expect(
        VersionCheck.fromJson(const {'latest_build': 4.0}).latestBuild,
        4,
      );
      expect(VersionCheck.fromJson(const {}).latestBuild, isNull);
    });
  });
}
