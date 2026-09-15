import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInParams extends Equatable {
  final String phone;
  final String pin;
  final UserRole role;
  const SignInParams({required this.phone, required this.pin, required this.role});

  @override
  List<Object?> get props => [phone, pin, role];
}

class SignIn implements UseCase<User, SignInParams> {
  final AuthRepository repository;
  SignIn(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) {
    return repository.signIn(phone: params.phone, pin: params.pin, role: params.role);
  }
}
