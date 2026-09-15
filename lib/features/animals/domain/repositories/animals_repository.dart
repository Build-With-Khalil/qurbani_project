import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/animal.dart';

abstract class AnimalsRepository {
  Future<Either<Failure, List<Animal>>> getAnimals();
  Future<Either<Failure, Animal?>> getAnimal(String tag);
}
