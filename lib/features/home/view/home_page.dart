import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/app/ui/suska_ui.dart';
import 'package:suska_starter/core/utils/formatters.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';

/// Beranda kerangka: sapaan untuk user yang login + pintasan ke layar
/// contoh. Ganti isinya dengan ringkasan aplikasi Anda.
class HomePage extends StatelessWidget {
  const HomePage({this.now, super.key});

  /// Jam untuk sapaan — disuntik di test agar hasilnya tetap.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthCubit, String>(
      (c) => c.state.user?.namaSdm ?? '',
    );
    final greeting = greetingForHour((now ?? DateTime.now()).hour);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: gradientAppBar(title: 'Beranda'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.screen),
        children: [
          PCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 18 / 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.isEmpty ? 'Pengguna' : user,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.stack),
          const PSectionHeader(title: 'Mulai dari sini'),
          const SizedBox(height: 12),
          PCard(
            onTap: () => context.go('/sample'),
            child: const _Shortcut(
              icon: Icons.list_alt,
              title: 'Layar daftar',
              caption: 'Filter, kartu, keadaan kosong dan galat',
            ),
          ),
          const SizedBox(height: 12),
          PCard(
            onTap: () => context.push('/sample/form'),
            child: const _Shortcut(
              icon: Icons.edit_note,
              title: 'Layar formulir',
              caption: 'Isian teks, dropdown, tanggal, validasi',
            ),
          ),
          const SizedBox(height: 12),
          PCard(
            onTap: () => context.go('/components'),
            child: const _Shortcut(
              icon: Icons.widgets_outlined,
              title: 'Kit komponen',
              caption: 'Semua komponen siap pakai',
            ),
          ),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                caption,
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textFaint),
      ],
    );
  }
}
