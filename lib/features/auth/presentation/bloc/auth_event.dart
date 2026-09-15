part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

class AuthRoleChanged extends AuthEvent {
  final UserRole role;
  const AuthRoleChanged(this.role);
  @override
  List<Object?> get props => [role];
}

class AuthPhoneChanged extends AuthEvent {
  final String phone;
  const AuthPhoneChanged(this.phone);
  @override
  List<Object?> get props => [phone];
}

class AuthPinChanged extends AuthEvent {
  final String pin;
  const AuthPinChanged(this.pin);
  @override
  List<Object?> get props => [pin];
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
