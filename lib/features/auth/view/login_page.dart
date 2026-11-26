import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/storage/terms_storage.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.apps, size: 96, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                AppConfig.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                AppConfig.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 48),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  final message = state.errorMessage;
                  if (message != null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                  }
                },
                builder: (context, state) {
                  final busy = state.status == AuthStatus.authenticating;
                  return FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                    ),
                    onPressed: busy
                        ? null
                        : () => unawaited(_signInGuarded(context)),
                    icon: busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(
                      busy ? 'Masuk…' : 'Masuk dengan akun UIN Suska',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// User baru wajib menyetujui Syarat & Ketentuan dulu.
  Future<void> _signInGuarded(BuildContext context) async {
    final accepted = await context.read<TermsStorage>().hasAccepted();
    if (!context.mounted) return;
    if (!accepted) {
      await context.push('/terms');
      return;
    }
    await context.read<AuthCubit>().signIn();
  }
}
