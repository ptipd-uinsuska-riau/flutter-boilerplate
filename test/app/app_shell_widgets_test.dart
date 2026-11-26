import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/app/view/app_shell.dart';

void main() {
  group('AppBottomBar', () {
    testWidgets('menampilkan 4 tab + meneruskan tap ke onSelect',
        (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomBar(
              currentIndex: 0,
              onSelect: taps.add,
            ),
          ),
        ),
      );

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Contoh'), findsOneWidget);
      expect(find.text('Komponen'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      // Label tombol aksi utama di slot tengah.
      expect(find.text('Tambah'), findsOneWidget);

      await tester.tap(find.text('Contoh'));
      await tester.tap(find.text('Profil'));
      expect(taps, [1, 3]);
    });
  });

  group('AppDrawer', () {
    testWidgets('menampilkan menu + logout dan meneruskan pilihan',
        (tester) async {
      final taps = <int>[];
      var loggedOut = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDrawer(
              currentIndex: 0,
              userName: 'Pegawai',
              onSelect: taps.add,
              onLogout: () => loggedOut = true,
            ),
          ),
        ),
      );

      expect(find.text('Pegawai'), findsOneWidget);
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Contoh'), findsOneWidget);
      expect(find.text('Komponen'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      await tester.tap(find.text('Contoh'));
      expect(taps, [1]);

      await tester.tap(find.text('Keluar'));
      expect(loggedOut, isTrue);
    });
  });
}
