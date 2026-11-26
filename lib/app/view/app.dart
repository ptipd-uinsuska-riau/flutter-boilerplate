import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:suska_starter/app/router.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/core/api/api_client.dart';
import 'package:suska_starter/core/api/ssot_api.dart';
import 'package:suska_starter/core/api/token_refresher.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/settings/text_scale_cubit.dart';
import 'package:suska_starter/core/storage/terms_storage.dart';
import 'package:suska_starter/core/storage/token_storage.dart';
import 'package:suska_starter/features/app_version/data/app_version_api.dart';
import 'package:suska_starter/features/app_version/data/update_decision.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';
import 'package:suska_starter/features/sample/data/sample_api.dart';
import 'package:suska_starter/l10n/l10n.dart';

/// Akar aplikasi: membuat SATU instance tiap layanan (token, ApiClient,
/// API per fitur) lalu membagikannya lewat `RepositoryProvider`.
///
/// Fitur baru: buat `XxxApi(_apiClient)` di sini, daftarkan di `providers`,
/// lalu layar mengambilnya dengan `context.read<XxxApi>()`.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final TokenStorage _tokenStorage;
  late final AuthRepository _authRepository;
  late final ApiClient _apiClient;
  late final SsotApi _ssotApi;
  late final SampleApi _sampleApi;
  late final AppVersionApi _appVersionApi;
  late final AuthCubit _authCubit;
  late final TextScaleCubit _textScaleCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _authRepository = AuthRepository(tokenStorage: _tokenStorage);
    _apiClient = ApiClient(
      tokenStorage: _tokenStorage,
      refresher: TokenRefresher(tokenStorage: _tokenStorage),
    );
    _ssotApi = SsotApi(tokenStorage: _tokenStorage);
    _sampleApi = SampleApi();
    _appVersionApi = AppVersionApi(_apiClient);
    _textScaleCubit = TextScaleCubit();
    unawaited(_textScaleCubit.load());
    unawaited(initializeDateFormatting('id_ID'));
    _authCubit = AuthCubit(repository: _authRepository);
    unawaited(_authCubit.checkSession());
    _router = buildRouter(_authCubit);
    unawaited(_checkAppVersion());
  }

  /// Cek versi saat aplikasi dibuka — tidak menahan apa pun; gagal cek
  /// (termasuk backend yang belum punya `GET /app/check-version`) diabaikan.
  Future<void> _checkAppVersion() async {
    try {
      final check = await _appVersionApi.checkVersion(
        platform: Platform.isIOS ? 'ios' : 'android',
        version: AppConfig.appVersion,
        build: AppConfig.appBuild,
      );
      final update = decideUpdate(
        check,
        installedVersion: AppConfig.appVersion,
        installedBuild: AppConfig.appBuild,
      );
      if (update != null) {
        await _router.push('/force-update', extra: update);
      }
    } on Object {
      // Versi tak bisa dicek bukan alasan menahan user.
    }
  }

  @override
  void dispose() {
    unawaited(_authCubit.close());
    unawaited(_textScaleCubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _tokenStorage),
        RepositoryProvider(create: (_) => TermsStorage()),
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _apiClient),
        RepositoryProvider.value(value: _ssotApi),
        RepositoryProvider.value(value: _sampleApi),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authCubit),
          BlocProvider.value(value: _textScaleCubit),
        ],
        child: MaterialApp.router(
          title: AppConfig.appName,
          theme: buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _router,
          // Skala teks pilihan user (aksesibilitas) — dikalikan skala sistem.
          builder: (context, child) {
            final scale = context.watch<TextScaleCubit>().state;
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: TextScaler.linear(mq.textScaler.scale(1) * scale),
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
