import 'package:flutter/material.dart';
import 'package:suska_starter/core/config/app_config.dart';
import 'package:suska_starter/features/legal/view/legal_widgets.dart';

/// Kebijakan Privasi.
///
/// ISI DI BAWAH HANYA KERANGKA. Ganti dengan naskah resmi sebelum rilis —
/// toko aplikasi menolak aplikasi yang kebijakan privasinya tidak
/// menyebut data yang benar-benar dikumpulkan.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalScaffold(
      title: 'Kebijakan Privasi',
      children: [
        Text(
          'Kebijakan Privasi Aplikasi ${AppConfig.appName}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        LegalParagraph(
          'Naskah ini belum diisi. Kebijakan privasi wajib disusun sesuai '
          'Undang-Undang Nomor 27 Tahun 2022 tentang Pelindungan Data '
          'Pribadi (UU PDP) sebelum aplikasi dirilis.',
        ),
        LegalHeading('1. Data yang Dikumpulkan'),
        LegalSubheading('Data akun:'),
        LegalBullet(
          'Nama, email, dan NIP dari akun yang dipakai untuk login.',
        ),
        LegalSubheading('Data lain:'),
        LegalBullet(
          'Tulis setiap data lain yang dikumpulkan aplikasi (lokasi, foto, '
          'berkas, dan seterusnya) beserta tujuannya.',
        ),
        LegalHeading('2. Penggunaan dan Penyimpanan'),
        LegalBullet('Tulis untuk apa data dipakai dan berapa lama disimpan.'),
        LegalHeading('3. Hak Pengguna'),
        LegalBullet(
          'Tulis cara pengguna meminta akses, perbaikan, atau penghapusan '
          'data.',
        ),
        LegalHeading('4. Kontak'),
        LegalParagraph('Tulis unit dan alamat yang bisa dihubungi.'),
        SizedBox(height: 24),
      ],
    );
  }
}
