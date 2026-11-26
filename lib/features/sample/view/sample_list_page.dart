import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/app/ui/suska_ui.dart';
import 'package:suska_starter/core/format/dates.dart';
import 'package:suska_starter/features/sample/cubit/sample_cubit.dart';
import 'package:suska_starter/features/sample/data/sample_api.dart';
import 'package:suska_starter/features/sample/data/sample_models.dart';

/// Layar daftar contoh — acuan untuk layar daftar lain:
/// chip filter → daftar kartu, dengan keadaan memuat, kosong, dan galat.
class SampleListPage extends StatelessWidget {
  const SampleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SampleCubit(api: context.read<SampleApi>());
        unawaited(cubit.load());
        return cubit;
      },
      child: const _SampleListView(),
    );
  }
}

class _SampleListView extends StatelessWidget {
  const _SampleListView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SampleCubit>().state;
    final cubit = context.read<SampleCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: gradientAppBar(title: 'Contoh'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpace.stack),
          PFilterChips(
            labels: SampleState.filters,
            selected: state.filter,
            onSelected: cubit.setFilter,
          ),
          Expanded(
            child: switch (state.load) {
              SampleLoad.loading =>
                const Center(child: CircularProgressIndicator()),
              SampleLoad.error => _ErrorView(
                  message: state.errorMessage ?? 'Gagal memuat data',
                  onRetry: () => unawaited(cubit.retry()),
                ),
              SampleLoad.ready => RefreshIndicator(
                  onRefresh: cubit.load,
                  child: state.visible.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 48),
                            PEmptyState(
                              title: 'Belum ada pengajuan',
                              message: 'Tekan tombol Tambah untuk membuat '
                                  'pengajuan baru.',
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.screen,
                            AppSpace.stack,
                            AppSpace.screen,
                            AppSpace.screen,
                          ),
                          itemCount: state.visible.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpace.stack),
                          itemBuilder: (_, i) =>
                              _SampleCard(item: state.visible[i]),
                        ),
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.item});

  final SampleItem item;

  @override
  Widget build(BuildContext context) {
    return PRequestCard(
      title: item.title,
      statusLabel: item.status.label,
      statusColor: switch (item.status) {
        SampleStatus.pending => AppColors.warning,
        SampleStatus.approved => AppColors.success,
        SampleStatus.rejected => AppColors.danger,
      },
      subtitle: item.category.isEmpty ? null : item.category,
      subtitleIcon: Icons.label_outline,
      captionLabel: item.note.isEmpty ? null : 'Catatan: ',
      captionValue: item.note.isEmpty ? null : item.note,
      startDate: formatIsoDate(item.startDate),
      endDate: formatIsoDate(item.endDate),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PEmptyState(
              title: 'Tidak dapat memuat',
              message: message,
              icon: Icons.cloud_off_outlined,
            ),
            const SizedBox(height: AppSpace.stack),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
