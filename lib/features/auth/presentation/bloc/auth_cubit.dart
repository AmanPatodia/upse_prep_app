import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_repository.dart';
import '../../domain/auth_models.dart';

class AuthState {
  const AuthState({this.currentUser, this.isBusy = false, this.errorMessage});

  final AppUser? currentUser;
  final bool isBusy;
  final String? errorMessage;

  bool get isLoggedIn => currentUser != null;

  AuthState copyWith({
    AppUser? currentUser,
    bool? isBusy,
    String? errorMessage,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: errorMessage,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthState());

  final AuthRepository _authRepository;

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    emit(state.copyWith(isBusy: true, errorMessage: null));
    final user = await _authRepository.login(
      identifier: identifier,
      password: password,
    );
    if (user == null) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage:
              'Invalid email/phone or password. Please sign up first or retry.',
        ),
      );
      return false;
    }

    emit(AuthState(currentUser: user, isBusy: false));
    return true;
  }

  Future<String?> signup({
    required String name,
    required String identifier,
    required String password,
  }) async {
    emit(state.copyWith(isBusy: true, errorMessage: null));
    final error = await _authRepository.signup(
      name: name,
      identifier: identifier,
      password: password,
    );
    if (error != null) {
      emit(state.copyWith(isBusy: false, errorMessage: error));
      return error;
    }

    emit(state.copyWith(isBusy: false));
    return null;
  }

  void logout() {
    emit(const AuthState());
  }
}
