import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/storage/terms_storage.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';

/// Layar pembuka/splash: gradasi teal→ink, cincin halus, logo dalam kartu
/// putih, tombol Mulai. Ganti ikon di kartu putih dengan logo aplikasi.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthCubit, AuthStatus>(
      (c) => c.state.status,
    );
    final showStart = status == AuthStatus.unauthenticated;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDeep,
              AppColors.inkTeal,
            ],
            stops: [0, .55, 1],
          ),
        ),
        child: Stack(
          children: [
            const _Ring(size: 520, top: -160, right: -180),
            const _Ring(size: 380, bottom: -120, left: -140),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 112,
                      height: 112,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 40,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.apps,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      AppConfig.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppConfig.appTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .85),
                        fontSize: 13.5,
                        height: 1.6,
                      ),
                    ),
                    const Spacer(),
                    if (showStart) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.inkTeal,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () => unawaited(_start(context)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Mulai'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'v${AppConfig.appVersion} · PTIPD UIN Suska Riau',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .55),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// User baru wajib lewat Syarat & Ketentuan dulu.
  Future<void> _start(BuildContext context) async {
    final accepted = await context.read<TermsStorage>().hasAccepted();
    if (!context.mounted) return;
    context.go(accepted ? '/login' : '/terms');
  }
}

/// Cincin dekoratif halus di latar.
class _Ring extends StatelessWidget {
  const _Ring({
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white10, width: 1.5),
          ),
        ),
      ),
    );
  }
}
