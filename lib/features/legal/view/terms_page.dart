import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/core/storage/terms_storage.dart';
import 'package:suska_starter/features/legal/view/legal_widgets.dart';

/// Syarat & Ketentuan — user baru harus menyetujui sebelum lanjut ke login.
///
/// ISI DI BAWAH HANYA KERANGKA. Ganti seluruh teksnya dengan naskah yang
/// disetujui pemilik aplikasi sebelum rilis; alur persetujuannya (centang →
/// simpan → login) sudah jadi dan diuji.
class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return LegalScaffold(
      title: 'Syarat & Ketentuan',
      footer: _buildFooter(context),
      children: [
        const Text(
          'Syarat dan Ketentuan Penggunaan Aplikasi ${AppConfig.appName}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const LegalParagraph(
          'Naskah ini belum diisi. Ganti dengan syarat dan ketentuan resmi '
          'aplikasi sebelum dirilis.',
        ),
        const LegalHeading('1. Penggunaan Aplikasi'),
        const LegalBullet('Tulis untuk apa aplikasi ini digunakan.'),
        const LegalBullet('Tulis kewajiban dan larangan bagi pengguna.'),
        const LegalHeading('2. Akun dan Autentikasi'),
        const LegalBullet(
          'Pengguna login dengan akun Google yang terdaftar pada sistem.',
        ),
        const LegalHeading('3. Data Pribadi'),
        const LegalParagraph(
          'Rincian data yang dikumpulkan dan cara penggunaannya dijelaskan '
          'di Kebijakan Privasi.',
        ),
        _PrivacyPolicyLink(
          onTap: () => unawaited(context.push('/privacy-policy')),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => setState(() => _agreed = !_agreed),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreed,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                  ),
                  const Expanded(
                    child: Text(
                      'Saya telah membaca dan menyetujui Syarat & Ketentuan '
                      'di atas',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _agreed ? () => _accept(context) : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Setuju & Lanjutkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _accept(BuildContext context) {
    unawaited(context.read<TermsStorage>().setAccepted());
    context.go('/login');
  }
}

class _PrivacyPolicyLink extends StatelessWidget {
  const _PrivacyPolicyLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Baca Kebijakan Privasi',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
