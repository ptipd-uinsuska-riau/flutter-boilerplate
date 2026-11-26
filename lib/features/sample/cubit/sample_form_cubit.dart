import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:suska_starter/core/api/api_envelope.dart';
import 'package:suska_starter/features/sample/data/sample_api.dart';
import 'package:suska_starter/features/sample/data/sample_models.dart';

part 'sample_form_state.dart';

/// Formulir pengajuan contoh: validasi di aplikasi dulu, baru kirim.
class SampleFormCubit extends Cubit<SampleFormState> {
  SampleFormCubit({required this._api}) : super(const SampleFormState());

  final SampleApi _api;

  void setTitle(String value) => emit(state.copyWith(title: value));
  void setCategory(String? value) => emit(state.copyWith(category: value));
  void setStartDate(DateTime value) => emit(state.copyWith(startDate: value));
  void setEndDate(DateTime value) => emit(state.copyWith(endDate: value));
  void setNote(String value) => emit(state.copyWith(note: value));

  /// `true` bila pengajuan terkirim.
  Future<bool> submit() async {
    if (state.submitting) return false;
    final invalid = state.validationError;
    if (invalid != null) {
      emit(state.copyWith(errorMessage: invalid));
      return false;
    }
    emit(state.copyWith(submitting: true));
    try {
      await _api.create(
        SampleDraft(
          title: state.title.trim(),
          category: state.category!,
          startDate: state.startDate!,
          endDate: state.endDate!,
          note: state.note.trim(),
        ),
      );
      emit(state.copyWith(submitting: false, submitted: true));
      return true;
    } on Exception catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: apiErrorMessage(e, fallback: 'Gagal mengirim'),
        ),
      );
      return false;
    }
  }
}
