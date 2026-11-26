import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet aplikasi — arah visual **flat + hairline**. Tidak ada gradasi
/// brand, tidak ada shadow tebal. Kedalaman dibentuk oleh garis 1px
/// `border` dan shadow 1px yang hampir tak terlihat.
///
/// Mengganti warna brand = ubah NILAI di kelas ini saja; layar tidak boleh
/// menulis `Color(0x…)` sendiri.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF02929A);
  static const primaryDeep = Color(0xFF017078);
  static const inkTeal = Color(0xFF0B3A3D);
  static const primaryLight = Color(0xFF5FB8BE);
  static const mint = Color(0xFFE0F2F3);

  // Status
  static const success = Color(0xFF0F9D58);
  static const warning = Color(0xFFF9AB00);
  static const danger = Color(0xFFD93025);
  static const info = Color(0xFF1A73E8);

  // Naik/turun di atas permukaan GELAP (kartu Estimasi P1) — `success`/
  // `danger` terlalu redup di sana.
  static const gain = Color(0xFF1FDB9B);
  static const loss = Color(0xFFF58A84);

  /// Latar lunak pasangan tiap status (badge, banner).
  static const successSoft = Color(0xFFE6F4EA);
  static const warningSoft = Color(0xFFFEF7E0);
  static const dangerSoft = Color(0xFFFCE8E6);
  static const infoSoft = Color(0xFFE8F0FE);

  // Netral
  static const text = Color(0xFF181C22);
  static const textSecondary = Color(0xFF404752);
  static const textMuted = Color(0xFF707784);
  static const textFaint = Color(0xFF9CA3AF);
  static const border = Color(0xFFDFE2EB);
  static const divider = Color(0xFFE5E7EB);
  /// Cincin 1px kartu besar (nilai Figma: rgb(192,199,213)).
  static const ring = Color(0xFFC0C7D5);
  static const background = Color(0xFFF4F4F4);

  /// Bayangan tipis di atas bottom bar.
  static const navShadow = Color(0x1A00C3D0);
  static const Color surface = Colors.white;

  /// Kompat lama — beberapa layar masih merujuk nama ini.
  static const Color primaryDark = primaryDeep;
}

/// Skala spasi & radius desain (390 px: kartu 342 → sisi 24).
abstract final class AppSpace {
  static const screen = 24.0; // nilai Figma: kartu 342 pada layar 390
  static const stack = 16.0;
  static const card = 20.0;
  static const headerHeight = 64.0;
}

abstract final class AppRadius {
  static const card = 16.0;
  /// Kartu besar / statistik (nilai Figma: 24).
  static const cardLg = 24.0;
  static const field = 12.0;
  static const chip = 999.0;
}

/// Header brand. Sekarang **rata** — kedua stop warna sama, sehingga semua
/// pemakaian `kHeaderGradient` yang sudah ada otomatis jadi teal solid tanpa
/// perlu menyentuh layarnya.
const kHeaderGradient = LinearGradient(
  colors: [AppColors.primary, AppColors.primary],
);

/// Aksen gelap (kartu remunerasi, FAB) — teal tinta, nyaris rata.
const kDarkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.inkTeal, Color(0xFF0E4A4E)],
);

/// Bayangan kartu — 0 1 2 rgba(0,0,0,.05), persis nilai Figma.
const kCardShadow = [
  BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  ),
];

/// Garis kartu standar (dipakai bersama `kCardShadow`).
final kCardBorder = Border.all(color: AppColors.border);

/// Dekorasi kartu putih standar — satu sumber kebenaran untuk semua kartu.
BoxDecoration cardDecoration({double radius = AppRadius.card}) => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
      boxShadow: kCardShadow,
    );

/// AppBar brand — teal solid, judul 700/20, tanpa gradasi.
/// Tanda tangan fungsi tidak berubah dari versi lama.
AppBar gradientAppBar({
  required String title,
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    title: Text(title),
    backgroundColor: AppColors.primary,
    surfaceTintColor: Colors.transparent,
    actions: actions,
    bottom: bottom,
    elevation: 0,
    scrolledUnderElevation: 0,
  );
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    surface: AppColors.surface,
  ).copyWith(
    primary: AppColors.primary,
    error: AppColors.danger,
  );
  final textTheme = GoogleFonts.interTextTheme().apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      toolbarHeight: AppSpace.headerHeight,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDeep,
        side: const BorderSide(color: AppColors.border),
        minimumSize: const Size.fromHeight(48),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDeep,
        textStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      side: const BorderSide(color: AppColors.border),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      // Nilai Figma "Form Section Cuti" (node 56:2802): isian #F8F8F8,
      // cincin 1px #CCCCCC, radius 12, teks 500 14/20.
      filled: true,
      fillColor: const Color(0xFFF8F8F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textFaint,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, space: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.inkTeal,
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.primaryDeep,
      unselectedLabelColor: AppColors.textSecondary,
      dividerColor: Colors.transparent,
      labelStyle: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
