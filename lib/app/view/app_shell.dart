import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/features/auth/cubit/auth_cubit.dart';

/// Kerangka tab utama: bar putih sudut atas 24 dengan empat tab dan satu
/// tombol aksi utama 64 px bercincin putih di tengah (labelnya di bawah
/// lingkaran), plus drawer.
///
/// Mengganti tab = ubah TIGA tempat sekaligus: cabang di `router.dart`,
/// item [AppBottomBar], dan item [AppDrawer]. Tombol tengah membuka aksi
/// utama aplikasi — di kerangka ini formulir contoh.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final userName =
        context.select<AuthCubit, String>((c) => c.state.user?.namaSdm ?? '');

    return Scaffold(
      drawer: Drawer(
        child: AppDrawer(
          currentIndex: shell.currentIndex,
          userName: userName,
          onSelect: (i) {
            Navigator.of(context).pop();
            shell.goBranch(i, initialLocation: i == shell.currentIndex);
          },
          onLogout: () {
            Navigator.of(context).pop();
            unawaited(context.read<AuthCubit>().signOut());
          },
        ),
      ),
      body: shell,
      floatingActionButton: Semantics(
        button: true,
        label: 'Tambah',
        child: GestureDetector(
          onTap: () => unawaited(context.push<bool>('/sample/form')),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomBar(
        currentIndex: shell.currentIndex,
        onSelect: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}

/// Bottom bar 4 item + slot tombol aksi utama di tengah:
/// Beranda · Contoh · `Tambah` · Komponen · Profil.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    required this.currentIndex,
    required this.onSelect,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navShadow,
            blurRadius: 4,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _TabItem(
                  icon: Icons.home,
                  label: 'Beranda',
                  selected: currentIndex == 0,
                  onTap: () => onSelect(0),
                ),
              ),
              Expanded(
                child: _TabItem(
                  icon: Icons.list_alt,
                  label: 'Contoh',
                  selected: currentIndex == 1,
                  onTap: () => onSelect(1),
                ),
              ),
              // Slot tombol aksi utama (FAB centerDocked) + labelnya.
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 26),
                  child: Text(
                    'Tambah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      height: 15 / 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ring,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _TabItem(
                  icon: Icons.widgets,
                  label: 'Komponen',
                  selected: currentIndex == 2,
                  onTap: () => onSelect(2),
                ),
              ),
              Expanded(
                child: _TabItem(
                  icon: Icons.person,
                  label: 'Profil',
                  selected: currentIndex == 3,
                  onTap: () => onSelect(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Nilai Figma: aktif teal penuh, non-aktif #C0C7D5 dengan opacity .8.
    final color = selected ? AppColors.primary : AppColors.ring;
    return Opacity(
      opacity: selected ? 1 : .8,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                height: 15 / 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Isi drawer — teal solid, item hairline.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.currentIndex,
    required this.userName,
    required this.onSelect,
    required this.onLogout,
    super.key,
  });

  final int currentIndex;
  final String userName;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Beranda'),
      (Icons.list_alt_outlined, 'Contoh'),
      (Icons.widgets_outlined, 'Komponen'),
      (Icons.person_outline, 'Profil'),
    ];
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Material(
      color: AppColors.primary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: .2), height: 1),
            const SizedBox(height: 8),
            for (final (i, (icon, label)) in items.indexed)
              ListTile(
                leading: Icon(icon, color: Colors.white, size: 22),
                title: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        i == currentIndex ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                selected: i == currentIndex,
                selectedTileColor: Colors.white.withValues(alpha: .12),
                onTap: () => onSelect(i),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: .6)),
                  ),
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Keluar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
