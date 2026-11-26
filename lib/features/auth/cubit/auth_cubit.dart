import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:suska_starter/core/cache/memory_cache.dart';
import 'package:suska_starter/features/auth/data/auth_models.dart';
import 'package:suska_starter/features/auth/data/auth_repository.dart';

part 'auth_state.dart';

/// Status login aplikasi. Router (`redirectFor`) membaca state ini untuk
/// memutuskan layar mana yang boleh dibuka.
///
/// Butuh langkah wajib setelah login (mis. melengkapi data)? Tambahkan
/// field "gate" di [AuthState] dan satu aturan di `redirectFor` — jangan
/// menaruh pengecekannya di tiap layar.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this._repository}) : super(const AuthState());

  final AuthRepository _repository;

  /// Dipanggil saat aplikasi dibuka: pakai sesi tersimpan bila ada, tanpa
  /// menunggu jaringan.
  Future<void> checkSession() async {
    await _repository.initialize();
    final hasSession = await _repository.hasSession;
    final user = hasSession ? await _repository.currentUser : null;
    emit(
      state.copyWith(
        status:
            hasSession ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        user: user,
      ),
    );
  }

  Future<void> signIn() async {
    emit(state.copyWith(status: AuthStatus.authenticating));
    try {
      final user = await _repository.signIn();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> signOut() async {
    // Data milik user lama tak boleh bocor ke user berikutnya.
    MemoryCache.clear();
    await _repository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
