import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suska_starter/core/settings/text_scale_cubit.dart';
import 'package:suska_starter/core/storage/terms_storage.dart';
import 'package:suska_starter/features/app_version/data/app_version_api.dart';
import 'package:suska_starter/features/app_version/view/force_update_page.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';
import 'package:suska_starter/features/auth/data/auth_models.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';
import 'package:suska_starter/features/auth/view/login_page.dart';
import 'package:suska_starter/features/auth/view/welcome_page.dart';
import 'package:suska_starter/features/components/view/components_page.dart';
import 'package:suska_starter/features/home/view/home_page.dart';
import 'package:suska_starter/features/legal/view/privacy_policy_page.dart';
import 'package:suska_starter/features/legal/view/terms_page.dart';
import 'package:suska_starter/features/profile/view/profile_page.dart';
import 'package:suska_starter/features/sample/data/sample_api.dart';
import 'package:suska_starter/features/sample/view/sample_form_page.dart';
import 'package:suska_starter/features/sample/view/sample_list_page.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// Smoke test responsivitas: SETIAP layar dipompa pada layar sempit
/// (320dp), standar (360dp), lebar (412dp), dan pada skala font
/// aksesibilitas 1.3 — overflow ("RenderFlex overflowed") otomatis
/// menggagalkan test.
///
/// HALAMAN BARU WAJIB DIDAFTARKAN di daftar `pages` di bawah. Font test
/// (Ahem) jauh lebih lebar daripada Inter, jadi layar yang lolos di sini
/// pasti lega di perangkat nyata.
void main() {
  const sizes = <(String, Size)>[
    ('320x568 (sempit)', Size(320, 568)),
    ('360x800 (standar)', Size(360, 800)),
    ('412x915 (lebar)', Size(412, 915)),
  ];

  const unauthenticated = AuthState(status: AuthStatus.unauthenticated);

  late AuthCubit authCubit;
  late TextScaleCubit textScaleCubit;

  setUpAll(() => initializeDateFormatting('id_ID'));

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    textScaleCubit = TextScaleCubit();
    authCubit = AuthCubit(repository: _MockAuthRepository())
      ..emit(
        const AuthState(
          status: AuthStatus.authenticated,
          // Nama panjang sengaja dipakai untuk memancing overflow.
          user: AuthUser(
            idSdm: 'S1',
            email: 'nama.pegawai.yang.panjang.sekali@uin-suska.ac.id',
            namaSdm: 'Nama Pegawai Yang Sangat Panjang Sekali, S.Kom., M.T.',
            nip: '199001012020121001',
            unitId: 'U1',
          ),
        ),
      );
  });

  tearDown(() async {
    await authCubit.close();
    await textScaleCubit.close();
  });

  Widget wrap(Widget page, {double textScale = 1.0}) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => SampleApi(delay: Duration.zero),
        ),
        RepositoryProvider(create: (_) => TermsStorage()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider.value(value: textScaleCubit),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: page,
        ),
      ),
    );
  }

  Future<void> pumpAt(
    WidgetTester tester,
    Widget page,
    Size size, {
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap(page, textScale: textScale));
    await tester.pumpAndSettle();
    // Gulir sampai dasar agar konten bawah ikut dibangun & diukur.
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isNotEmpty) {
      await tester.drag(scrollables.first, const Offset(0, -3000));
      await tester.pumpAndSettle();
    }
  }

  // (nama, halaman, sudah login?) — layar pra-login dipompa tanpa sesi;
  // WelcomePage dengan sesi hanya menampilkan spinner tanpa henti.
  final pages = <(String, Widget, bool)>[
    ('Selamat Datang', const WelcomePage(), false),
    ('Login', const LoginPage(), false),
    ('Syarat & Ketentuan', const TermsPage(), false),
    ('Kebijakan Privasi', const PrivacyPolicyPage(), false),
    ('Beranda', const HomePage(), true),
    ('Contoh (daftar)', const SampleListPage(), true),
    ('Contoh (formulir)', const SampleFormPage(), true),
    ('Komponen', const ComponentsPage(), true),
    ('Profil', const ProfilePage(), true),
    (
      'Perbarui Aplikasi',
      const ForceUpdatePage(
        check: VersionCheck(
          updateAvailable: true,
          isRequired: false,
          latestVersion: '9.9.9',
          releaseNotes: 'Catatan rilis yang cukup panjang untuk menguji '
              'pembungkusan teks di layar sempit.',
        ),
      ),
      true,
    ),
  ];

  for (final (pageName, page, loggedIn) in pages) {
    for (final (sizeName, size) in sizes) {
      testWidgets('$pageName muat tanpa overflow di $sizeName',
          (tester) async {
        if (!loggedIn) authCubit.emit(unauthenticated);
        await pumpAt(tester, page, size);
      });
    }

    testWidgets('$pageName muat tanpa overflow pada skala font 1.3 (360dp)',
        (tester) async {
      if (!loggedIn) authCubit.emit(unauthenticated);
      await pumpAt(tester, page, const Size(360, 800), textScale: 1.3);
    });
  }
}
