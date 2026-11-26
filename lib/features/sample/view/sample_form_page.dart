import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:suska_starter/app/theme.dart';
import 'package:suska_starter/app/ui/suska_ui.dart';
import 'package:suska_starter/features/sample/cubit/sample_form_cubit.dart';
import 'package:suska_starter/features/sample/data/sample_api.dart';

/// Formulir contoh — acuan untuk layar isian lain:
/// `PFormPanel` berisi `PField` (teks, dropdown, tanggal) + tombol kirim.
class SampleFormPage extends StatelessWidget {
  const SampleFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SampleFormCubit(api: context.read<SampleApi>()),
      child: const _SampleFormView(),
    );
  }
}

class _SampleFormView extends StatelessWidget {
  const _SampleFormView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SampleFormCubit>().state;
    final cubit = context.read<SampleFormCubit>();

    return BlocListener<SampleFormCubit, SampleFormState>(
      listenWhen: (a, b) =>
          a.errorMessage != b.errorMessage || a.submitted != b.submitted,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.submitted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Pengajuan terkirim')),
          );
          context.pop(true);
          return;
        }
        final message = state.errorMessage;
        if (message != null) {
          messenger.showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: gradientAppBar(title: 'Pengajuan Baru'),
        body: ListView(
          padding: const EdgeInsets.all(AppSpace.screen),
          children: [
            PFormPanel(
              children: [
                PField(
                  label: 'Judul',
                  child: TextField(
                    onChanged: cubit.setTitle,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Tulis judul pengajuan',
                    ),
                  ),
                ),
                PField(
                  label: 'Kategori',
                  child: PDropdownField<String>(
                    value: state.category,
                    items: SampleFormState.categories,
                    labelOf: (c) => c,
                    onChanged: cubit.setCategory,
                    hint: 'Pilih kategori',
                  ),
                ),
                PField(
                  label: 'Tanggal Mulai',
                  child: PDateField(
                    value: state.startDate,
                    onPick: cubit.setStartDate,
                  ),
                ),
                PField(
                  label: 'Tanggal Selesai',
                  child: PDateField(
                    value: state.endDate,
                    onPick: cubit.setEndDate,
                  ),
                ),
                PField(
                  label: 'Catatan',
                  child: TextField(
                    onChanged: cubit.setNote,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Opsional',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.stack),
            FilledButton(
              onPressed:
                  state.submitting ? null : () => unawaited(cubit.submit()),
              child: Text(state.submitting ? 'Mengirim…' : 'Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
