part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final UserRole role;
  final String phone;
  final String pin;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.role = UserRole.admin,
    this.phone = '',
    this.pin = '',
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    UserRole? role,
    String? phone,
    String? pin,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      pin: pin ?? this.pin,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, role, phone, pin, errorMessage];
}
