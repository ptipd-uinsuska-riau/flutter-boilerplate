import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suska_starter/features/app_version/data/app_version_api.dart';
import 'package:suska_starter/features/app_version/view/force_update_page.dart';

void main() {
  const required_ = VersionCheck(
    updateAvailable: true,
    isRequired: true,
    latestVersion: '2.0.0',
    releaseNotes: 'Perbaikan bug.',
  );
  const optional = VersionCheck(
    updateAvailable: true,
    isRequired: false,
    latestVersion: '1.1.0',
  );

  Future<void> pumpPage(WidgetTester tester, VersionCheck check) async {
    await tester.pumpWidget(
      MaterialApp(home: ForceUpdatePage(check: check)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('update wajib: judul blokir, tanpa "Nanti Saja"',
      (tester) async {
    await pumpPage(tester, required_);

    expect(find.text('Update Diperlukan'), findsOneWidget);
    expect(find.text('Update Sekarang'), findsOneWidget);
    expect(find.text('Nanti Saja'), findsNothing);
    expect(find.text('Versi 2.0.0'), findsOneWidget);
    expect(find.text('Perbaikan bug.'), findsOneWidget);
  });

  testWidgets('update opsional: judul tersedia + tombol "Nanti Saja"',
      (tester) async {
    await pumpPage(tester, optional);

    expect(find.text('Update Tersedia'), findsOneWidget);
    expect(find.text('Nanti Saja'), findsOneWidget);
  });

  testWidgets('update wajib memblokir tombol back', (tester) async {
    await pumpPage(tester, required_);

    final popped = await tester.state<NavigatorState>(
      find.byType(Navigator),
    ).maybePop();

    expect(popped, isTrue); // ditangani (diblokir) oleh PopScope
    await tester.pumpAndSettle();
    expect(find.text('Update Diperlukan'), findsOneWidget);
  });
}
