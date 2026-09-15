import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/animal.dart';
import '../repositories/animals_repository.dart';

class GetCowDetail implements UseCase<Animal?, String> {
  final AnimalsRepository repository;
  GetCowDetail(this.repository);

  @override
  Future<Either<Failure, Animal?>> call(String params) =>
      repository.getAnimal(params);
}
