import 'package:flutter/material.dart';
import 'package:suska_starter/app/theme.dart';

/// Kit komponen aplikasi — arah visual flat/hairline.
///
/// Semua layar memakai widget di file ini; tidak ada layar yang boleh
/// mendeklarasikan warna, radius, atau shadow sendiri.

/// Kartu putih standar: radius 16, border 1px, padding 20.
class PCard extends StatelessWidget {
  const PCard({
    required this.child,
    this.padding = AppSpace.card,
    this.onTap,
    super.key,
  });

  final Widget child;
  final double padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: cardDecoration(),
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: card,
    );
  }
}

/// Badge status pil + titik. Label diberikan pemanggil agar tetap memakai
/// `statusLabel()` milik fitur (teks Indonesia tidak berubah).
class PStatusBadge extends StatelessWidget {
  const PStatusBadge({required this.label, required this.color, super.key});

  const PStatusBadge.approved({Key? key})
      : this(label: 'Disetujui', color: AppColors.success, key: key);

  const PStatusBadge.pending({Key? key})
      : this(label: 'Menunggu', color: AppColors.warning, key: key);

  const PStatusBadge.rejected({Key? key})
      : this(label: 'Ditolak', color: AppColors.danger, key: key);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Judul seksi + aksi teks di kanan ("Lihat Semua").
class PSectionHeader extends StatelessWidget {
  const PSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              height: 22 / 15,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// Baris label–nilai (dipakai di kartu riwayat, detail, profil).
class PRow extends StatelessWidget {
  const PRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              height: 16 / 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                height: 18 / 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu pengajuan (cuti / dinas): judul + badge, garis, dua baris tanggal.
///
/// Susunan prototipe: judul + badge → [subtitle] (opsional berikon, mis.
/// pin lokasi) → [captionLabel]+[captionValue] ("Keperluan: …"/"Alasan: …")
/// → garis → kolom Mulai/Selesai bila [startDate]+[endDate] diberikan →
/// [rows] label–nilai tambahan → [footer] (deretan aksi rata kanan).
class PRequestCard extends StatelessWidget {
  const PRequestCard({
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    this.rows = const [],
    this.subtitle,
    this.subtitleIcon,
    this.captionLabel,
    this.captionValue,
    this.startDate,
    this.endDate,
    this.footer,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? subtitleIcon;

  /// Baris keterangan sekunder di bawah subtitle, dipecah label + nilai
  /// (mis. "Keperluan: " + isi) agar nilai tetap satu `Text` utuh — test
  /// widget mencari teksnya secara eksak.
  final String? captionLabel;
  final String? captionValue;
  final String statusLabel;
  final Color statusColor;

  /// Kolom "Mulai"/"Selesai" dua sisi (nilai Figma) — keduanya wajib terisi
  /// agar blok dirender.
  final String? startDate;
  final String? endDate;

  /// Pasangan label–nilai, mis. ('Durasi', '3 hari').
  final List<(String, String)> rows;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const secondaryStyle = TextStyle(
      fontSize: 12,
      height: 16 / 12,
      color: AppColors.textSecondary,
    );
    final hasRange = startDate != null && endDate != null;

    return PCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            if (subtitleIcon != null) ...[
                              Icon(
                                subtitleIcon,
                                size: 13,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(subtitle!, style: secondaryStyle),
                            ),
                          ],
                        ),
                      ),
                    if (captionValue != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        // Wrap (bukan Row): label boleh turun baris di ruang
                        // sempit/skala font besar alih-alih meluap.
                        child: Wrap(
                          children: [
                            if (captionLabel != null)
                              Text(captionLabel!, style: secondaryStyle),
                            Text(
                              captionValue!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: secondaryStyle,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PStatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          if (hasRange) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Expanded(
                  child: _RangeCell(label: 'Mulai', value: startDate!),
                ),
                Container(width: 24, height: 1, color: AppColors.divider),
                Expanded(
                  child: _RangeCell(
                    label: 'Selesai',
                    value: endDate!,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ],
          if (rows.isNotEmpty) ...[
            if (!hasRange)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              )
            else
              const SizedBox(height: 8),
            for (final (label, value) in rows) PRow(label: label, value: value),
          ],
          if (footer != null) ...[const SizedBox(height: 4), footer!],
        ],
      ),
    );
  }
}

/// Satu sisi kolom Mulai/Selesai pada [PRequestCard].
class _RangeCell extends StatelessWidget {
  const _RangeCell({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            height: 16 / 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

/// Kartu statistik kecil berikon (saldo Sakit/Darurat, bento pendamping).
class PMiniStat extends StatelessWidget {
  const PMiniStat({
    required this.icon,
    required this.title,
    required this.caption,
    super.key,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kCardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: AppColors.primaryDeep),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 16 / 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Deretan chip filter — nilai Figma "Filter Chips" (node 47:704):
/// pil padding 8/20, teks 500 12/16 spasi huruf .5; aktif teal + teks putih
/// (shadow 0 1 2 rgba(0,0,0,.05)), non-aktif latar #E6F4F5 teks #404752.
class PFilterChips extends StatelessWidget {
  const PFilterChips({
    required this.labels,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
      child: Row(
        children: [
          for (final (i, label) in labels.indexed)
            Padding(
              padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 8),
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: i == selected
                        ? AppColors.primary
                        : const Color(0xFFE6F4F5),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    boxShadow: i == selected ? kCardShadow : null,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      letterSpacing: .5,
                      fontWeight: FontWeight.w500,
                      color: i == selected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kartu metrik bento — nilai Figma "Section - Bento Grid: Sisa Cuti"
/// (node 49:800): radius 12, padding 16, ikon + eyebrow teal 600 12/16
/// uppercase, label 400 14/20 #475569, angka 700 36.
class PMetric extends StatelessWidget {
  const PMetric({
    required this.eyebrow,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.eyebrowColor = AppColors.primary,
    this.valueColor = AppColors.text,
    super.key,
  });

  final String eyebrow;
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color eyebrowColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: eyebrowColor),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  eyebrow.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: eyebrowColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: Color(0xFF475569),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Angka menyusut di ruang sempit/skala font besar.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 36,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: valueColor,
                      ),
                    ),
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel form — nilai Figma "Form Section Cuti" (node 56:2802): radius 24,
/// latar #FBFFFF, shadow 0 1 2, isi padding 16/24 dengan jarak antar field 24.
class PFormPanel extends StatelessWidget {
  const PFormPanel({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFFFF),
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        boxShadow: kCardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, child) in children.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == children.length - 1 ? 0 : 24,
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// Label + field, jarak 12 (nilai Figma), label 600 14/20 #111827.
class PField extends StatelessWidget {
  const PField({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Kotak isian non-TextField (tanggal, dropdown) — latar #F8F8F8, cincin 1px
/// #CCCCCC, radius 12, slot ikon kiri 40 px seperti Figma.
class PFieldBox extends StatelessWidget {
  const PFieldBox({
    required this.child,
    this.onTap,
    this.height = 44,
    this.leading,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double height;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Container(
        height: height,
        padding: EdgeInsets.only(left: leading == null ? 12 : 0, right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Row(
          children: [
            if (leading != null)
              SizedBox(
                width: 40,
                child: Icon(leading, size: 18, color: AppColors.textMuted),
              ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Field tanggal — memakai `showDatePicker` bawaan, format dd/MM/yyyy.
class PDateField extends StatelessWidget {
  const PDateField({
    required this.value,
    required this.onPick,
    this.hint = 'Pilih tanggal',
    this.firstDate,
    this.lastDate,
    super.key,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onPick;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final v = value;
    final text = v == null
        ? hint
        : '${v.day.toString().padLeft(2, '0')}/'
            '${v.month.toString().padLeft(2, '0')}/${v.year}';
    final now = DateTime.now();
    return PFieldBox(
      leading: Icons.calendar_today_outlined,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: v ?? now,
          firstDate: firstDate ?? DateTime(now.year - 1),
          lastDate: lastDate ?? DateTime(now.year + 2),
          locale: const Locale('id', 'ID'),
        );
        if (picked != null) onPick(picked);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w500,
          color: v == null ? AppColors.textFaint : const Color(0xFF111827),
        ),
      ),
    );
  }
}

/// Dropdown dengan bingkai seragam.
class PDropdownField<T> extends StatelessWidget {
  const PDropdownField({
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.hint = 'Pilih',
    super.key,
  });

  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF111827),
    );
    return PFieldBox(
      leading: Icons.list_alt_outlined,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(AppRadius.field),
          icon: const Icon(
            Icons.expand_more,
            size: 20,
            color: AppColors.textSecondary,
          ),
          hint: Text(
            hint,
            style: style.copyWith(color: AppColors.textFaint),
          ),
          style: style,
          items: [
            for (final item in items)
              DropdownMenuItem<T>(value: item, child: Text(labelOf(item))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Area unggah lampiran — garis putus-putus, bukan kotak solid.
class PUploadField extends StatelessWidget {
  const PUploadField({
    required this.onTap,
    this.fileName,
    this.hint = 'Unggah lampiran (PDF/JPG, maks 2 MB)',
    super.key,
  });

  final VoidCallback onTap;
  final String? fileName;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: CustomPaint(
        painter: const PDashedBorderPainter(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              const Icon(
                Icons.upload_file_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  fileName ?? hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: fileName == null
                        ? AppColors.textSecondary
                        : AppColors.text,
                    fontWeight:
                        fileName == null ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PDashedBorderPainter extends CustomPainter {
  const PDashedBorderPainter({
    this.color = AppColors.border,
    this.radius = AppRadius.field,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(.5, .5, size.width - 1, size.height - 1),
          Radius.circular(radius),
        ),
      );
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant PDashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

/// Keadaan kosong seragam (menggantikan blok Icon+Text ad-hoc di tiap layar).
class PEmptyState extends StatelessWidget {
  const PEmptyState({
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  /// Judul opsional — dirender sebagai `Text` terpisah di atas [message]
  /// (test lama mencari label judul sebagai widget sendiri).
  final String? title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Icon(icon, size: 26, color: AppColors.primaryDeep),
          ),
          const SizedBox(height: 12),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
