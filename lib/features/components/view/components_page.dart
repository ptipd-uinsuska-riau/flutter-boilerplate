import 'package:flutter/material.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/app/ui/suska_ui.dart';

/// Galeri kit komponen (`lib/app/ui/suska_ui.dart`).
///
/// Lihat di sini dulu sebelum membuat widget baru: kartu, badge, baris
/// label–nilai, statistik, chip, dan isian formulir sudah tersedia. Angka
/// dan teks di halaman ini hanya peraga.
class ComponentsPage extends StatefulWidget {
  const ComponentsPage({super.key});

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  int _chip = 0;
  String? _choice;
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: gradientAppBar(title: 'Komponen'),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.screen),
        children: [
          const _Section('PCard · PRow · PStatusBadge'),
          _Pad(
            child: PCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PStatusBadge.approved(),
                      PStatusBadge.pending(),
                      PStatusBadge.rejected(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const PRow(label: 'Label', value: 'Nilai'),
                  const PRow(label: 'Belum tersedia', value: '-'),
                  PSectionHeader(
                    title: 'PSectionHeader',
                    actionLabel: 'Lihat Semua',
                    onAction: () {},
                  ),
                ],
              ),
            ),
          ),
          const _Section('PMetric · PMiniStat'),
          const _Pad(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PMetric(
                    eyebrow: 'Peraga',
                    label: 'Jumlah',
                    value: '12',
                    unit: 'item',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: PMetric(
                    eyebrow: 'Peraga',
                    label: 'Belum ada data',
                    value: '-',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _Pad(
            child: PMiniStat(
              icon: Icons.schedule,
              title: 'PMiniStat',
              caption: 'Ikon + judul + keterangan satu baris',
            ),
          ),
          const _Section('PFilterChips'),
          PFilterChips(
            labels: const ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'],
            selected: _chip,
            onSelected: (i) => setState(() => _chip = i),
          ),
          const _Section('PRequestCard'),
          const _Pad(
            child: PRequestCard(
              title: 'Judul pengajuan',
              statusLabel: 'Menunggu',
              statusColor: AppColors.warning,
              subtitle: 'Subjudul berikon',
              subtitleIcon: Icons.place_outlined,
              captionLabel: 'Catatan: ',
              captionValue: 'keterangan singkat',
              startDate: '20 Agu 2026',
              endDate: '21 Agu 2026',
              rows: [('Durasi', '2 hari')],
            ),
          ),
          const _Section('PFormPanel · PField'),
          _Pad(
            child: PFormPanel(
              children: [
                const PField(
                  label: 'Isian teks',
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Tulis di sini'),
                  ),
                ),
                PField(
                  label: 'PDropdownField',
                  child: PDropdownField<String>(
                    value: _choice,
                    items: const ['Pilihan A', 'Pilihan B'],
                    labelOf: (v) => v,
                    onChanged: (v) => setState(() => _choice = v),
                  ),
                ),
                PField(
                  label: 'PDateField',
                  child: PDateField(
                    value: _date,
                    onPick: (d) => setState(() => _date = d),
                  ),
                ),
                PField(
                  label: 'PUploadField',
                  child: PUploadField(onTap: () {}),
                ),
              ],
            ),
          ),
          const _Section('PEmptyState'),
          const PEmptyState(
            title: 'Belum ada data',
            message: 'Dipakai untuk keadaan kosong di semua layar.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.stack,
        AppSpace.screen,
        12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: child,
    );
  }
}
