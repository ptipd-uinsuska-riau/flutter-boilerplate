import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/features/app_version/data/app_version_api.dart';
import 'package:url_launcher/url_launcher.dart';

/// Layar pembaruan aplikasi.
/// Bila [VersionCheck.isRequired], layar memblokir total (back dimatikan
/// dan tanpa tombol "Nanti Saja").
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({required this.check, super.key});

  final VersionCheck check;

  @override
  Widget build(BuildContext context) {
    final required_ = check.isRequired;

    return PopScope(
      canPop: !required_,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          // Bisa digulir: di layar pendek / teks besar isi tidak terpotong.
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: AppColors.mint,
                    child: Icon(
                      required_ ? Icons.system_update : Icons.update,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    required_ ? 'Update Diperlukan' : 'Update Tersedia',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    required_
                        ? 'Versi aplikasi Anda sudah tidak didukung. Silakan '
                              'update ke versi terbaru untuk melanjutkan.'
                        : 'Versi terbaru aplikasi sudah tersedia. Update '
                              'sekarang untuk mendapatkan fitur dan perbaikan '
                              'terbaru.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  if (check.latestVersion.isNotEmpty)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F5F3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Versi ${check.latestVersion}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (check.releaseNotes?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Catatan Perubahan:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            check.releaseNotes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _openStore,
                    icon: const Icon(Icons.download),
                    label: const Text('Update Sekarang'),
                  ),
                  if (!required_)
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Nanti Saja',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openStore() {
    final url = (check.downloadUrl?.isNotEmpty ?? false)
        ? check.downloadUrl!
        : AppConfig.storeUrl;
    // Tak ada tautan dari backend maupun `AppConfig.storeUrl` → tak ada
    // yang bisa dibuka.
    if (url.isEmpty) return;
    unawaited(
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    );
  }
}
