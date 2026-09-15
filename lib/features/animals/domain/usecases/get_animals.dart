import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/animal.dart';
import '../repositories/animals_repository.dart';

class GetAnimals implements UseCase<List<Animal>, NoParams> {
  final AnimalsRepository repository;
  GetAnimals(this.repository);

  @override
  Future<Either<Failure, List<Animal>>> call(NoParams params) =>
      repository.getAnimals();
}
