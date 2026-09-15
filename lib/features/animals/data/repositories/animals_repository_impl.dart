import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animals_repository.dart';
import '../datasources/animals_local_datasource.dart';

class AnimalsRepositoryImpl implements AnimalsRepository {
  final AnimalsLocalDataSource remote;
  AnimalsRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Animal>>> getAnimals() async {
    try {
      return Right(await remote.getAnimals());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Animal?>> getAnimal(String tag) async {
    try {
      return Right(await remote.getAnimal(tag));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
