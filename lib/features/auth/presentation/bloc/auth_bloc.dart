import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.signIn,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(const AuthState()) {
    on<AuthAppStarted>(_onStarted);
    on<AuthRoleChanged>(
      (e, emit) => emit(state.copyWith(role: e.role, clearError: true)),
    );
    on<AuthPhoneChanged>(
      (e, emit) => emit(state.copyWith(phone: e.phone, clearError: true)),
    );
    on<AuthPinChanged>(
      (e, emit) => emit(state.copyWith(pin: e.pin, clearError: true)),
    );
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
  }

  Future<void> _onStarted(AuthAppStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await getCurrentUser(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.unauthenticated)),
      (user) {
        if (user != null) {
          emit(state.copyWith(status: AuthStatus.authenticated, user: user));
        } else {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
      },
    );
  }

  Future<void> _onSignIn(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await signIn(SignInParams(
      phone: state.phone,
      pin: state.pin,
      role: state.role,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      )),
    );
  }

  Future<void> _onSignOut(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await signOut(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
