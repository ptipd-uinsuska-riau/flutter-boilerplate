import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suska_starter/app/view/app_shell.dart';
import 'package:suska_starter/features/app_version/data/app_version_api.dart';
import 'package:suska_starter/features/app_version/view/force_update_page.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';
import 'package:suska_starter/features/auth/view/login_page.dart';
import 'package:suska_starter/features/auth/view/welcome_page.dart';
import 'package:suska_starter/features/components/view/components_page.dart';
import 'package:suska_starter/features/home/view/home_page.dart';
import 'package:suska_starter/features/legal/view/privacy_policy_page.dart';
import 'package:suska_starter/features/legal/view/terms_page.dart';
import 'package:suska_starter/features/profile/view/profile_page.dart';
import 'package:suska_starter/features/sample/view/sample_form_page.dart';
import 'package:suska_starter/features/sample/view/sample_list_page.dart';

/// Aturan redirect terpusat — fungsi murni agar mudah diuji; [location]
/// adalah `matchedLocation` tanpa query.
///
/// Langkah wajib setelah login (mis. melengkapi data) ditambahkan DI SINI
/// sebagai satu aturan, bukan dicek di tiap layar.
@visibleForTesting
String? redirectFor(AuthState auth, String location) {
  // Layar pembaruan dicek/ditampilkan di luar siklus auth.
  if (location == '/force-update') return null;

  final onWelcome = location == '/welcome';
  // Halaman legal boleh dibaca sebelum login (alur persetujuan syarat).
  final public = location == '/login' ||
      location == '/terms' ||
      location == '/privacy-policy';

  // Splash saat sesi tersimpan masih dicek.
  if (auth.status == AuthStatus.unknown) return onWelcome ? null : '/welcome';
  if (auth.status != AuthStatus.authenticated) {
    return (onWelcome || public) ? null : '/welcome';
  }

  if (onWelcome || location == '/login') return '/';
  return null;
}

/// Halaman bertransisi pudar (tanpa geser) untuk splash & kerangka tab.
///
/// Transisi bawaan di iOS (Cupertino) menggeser halaman baru dari kanan,
/// sehingga perpindahan splash → Beranda tampak sebagai panel kosong yang
/// menutupi splash. Pudar singkat terasa seperti splash yang menghilang.
@visibleForTesting
CustomTransitionPage<void> fadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, _, child) => FadeTransition(
      opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
      child: child,
    ),
  );
}

GoRouter buildRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _CubitListenable(authCubit),
    redirect: (context, state) =>
        redirectFor(authCubit.state, state.matchedLocation),
    routes: [
      GoRoute(
        path: '/welcome',
        pageBuilder: (_, state) =>
            fadePage(key: state.pageKey, child: const WelcomePage()),
      ),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/terms', builder: (_, _) => const TermsPage()),
      GoRoute(
        path: '/privacy-policy',
        builder: (_, _) => const PrivacyPolicyPage(),
      ),
      // Tab utama dalam kerangka bottom bar + drawer.
      StatefulShellRoute.indexedStack(
        pageBuilder: (_, state, shell) =>
            fadePage(key: state.pageKey, child: AppShell(shell: shell)),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', builder: (_, _) => const HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sample',
                builder: (_, _) => const SampleListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/components',
                builder: (_, _) => const ComponentsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      // Rute di luar kerangka tab (tanpa bottom bar).
      GoRoute(
        path: '/sample/form',
        builder: (_, _) => const SampleFormPage(),
      ),
      GoRoute(
        path: '/force-update',
        builder: (_, state) =>
            ForceUpdatePage(check: state.extra! as VersionCheck),
      ),
    ],
  );
}

/// Adapter agar GoRouter ikut refresh saat state [AuthCubit] berubah.
class _CubitListenable extends ChangeNotifier {
  _CubitListenable(AuthCubit cubit) {
    _sub = cubit.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}
