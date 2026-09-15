import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource remote;
  AuthRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, User>> signIn({
    required String phone,
    required String pin,
    required UserRole role,
  }) async {
    try {
      final user = await remote.signIn(phone: phone, pin: pin, role: role);
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remote.signOut();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      return Right(await remote.getCurrentUser());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
