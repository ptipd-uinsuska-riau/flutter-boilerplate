import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/app/ui/suska_ui.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/settings/text_scale_cubit.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';

/// Profil kerangka: data akun dari login SSOT, setelan Ukuran Teks, tautan
/// halaman legal, dan Keluar.
///
/// Data yang TIDAK ada di respons login (jabatan, unit, foto) sengaja tidak
/// ditampilkan — ambil lewat `SsotApi` bila aplikasi membutuhkannya, dan
/// tampilkan `-` selama belum tersedia. Jangan mengarang nilai.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Record punya kesetaraan nilai → layar hanya dibangun ulang saat salah
    // satu field ini berubah.
    final user = context
        .select<AuthCubit, ({String name, String nip, String email})>(
          (c) => (
            name: c.state.user?.namaSdm ?? '',
            nip: c.state.user?.nip ?? '',
            email: c.state.user?.email ?? '',
          ),
        );
    final scale = context.watch<TextScaleCubit>().state;
    final scaleLabel = TextScaleCubit.options
        .firstWhere(
          (o) => o.$2 == scale,
          orElse: () => TextScaleCubit.options.first,
        )
        .$1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: gradientAppBar(title: 'Profil'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.screen),
        children: [
          PCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _orDash(user.name),
                  style: const TextStyle(
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                PRow(label: 'NIP', value: _orDash(user.nip)),
                PRow(label: 'Email', value: _orDash(user.email)),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.stack),
          const PSectionHeader(title: 'Pengaturan'),
          const SizedBox(height: 12),
          PCard(
            padding: 4,
            child: Column(
              children: [
                _Tile(
                  icon: Icons.format_size,
                  label: 'Ukuran Teks',
                  value: scaleLabel,
                  onTap: () => unawaited(
                    showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      builder: (_) => const TextScaleSheet(),
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                _Tile(
                  icon: Icons.description_outlined,
                  label: 'Syarat & Ketentuan',
                  onTap: () => unawaited(context.push('/terms')),
                ),
                const Divider(height: 1, color: AppColors.divider),
                _Tile(
                  icon: Icons.shield_outlined,
                  label: 'Kebijakan Privasi',
                  onTap: () => unawaited(context.push('/privacy-policy')),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.stack),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger.withValues(alpha: .4)),
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Keluar'),
          ),
          const SizedBox(height: AppSpace.stack),
          const Text(
            'Versi ${AppConfig.appVersion} (${AppConfig.appBuild})',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  static String _orDash(String value) => value.isEmpty ? '-' : value;

  void _confirmLogout(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                unawaited(context.read<AuthCubit>().signOut());
              },
              child: const Text(
                'Ya, Keluar',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Bukan ListTile: ListTile di dalam kartu berlatar (DecoratedBox)
    // kehilangan efek tekan dan memicu assertion Flutter.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.field),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    if (value != null)
                      Text(
                        value!,
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
          ),
        ),
      ),
    );
  }
}

/// Lembar pilihan "Ukuran Teks" (aksesibilitas — membantu pengguna lanjut
/// usia). Pilihan langsung diterapkan di seluruh aplikasi dan tersimpan.
class TextScaleSheet extends StatelessWidget {
  const TextScaleSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final current = context.watch<TextScaleCubit>().state;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text(
              'Ukuran Teks',
              style: TextStyle(
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Berlaku di seluruh aplikasi dan tersimpan.',
              style: TextStyle(
                fontSize: 12.5,
                height: 18 / 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          RadioGroup<double>(
            groupValue: current,
            onChanged: (v) {
              if (v != null) {
                unawaited(context.read<TextScaleCubit>().setScale(v));
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (label, value) in TextScaleCubit.options)
                  RadioListTile<double>(
                    value: value,
                    activeColor: AppColors.primary,
                    title: Text(
                      label,
                      // Pratinjau: label dirender pada skalanya sendiri.
                      textScaler: TextScaler.linear(value),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
