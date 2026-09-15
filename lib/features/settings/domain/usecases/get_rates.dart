import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rate.dart';
import '../repositories/settings_repository.dart';

class GetRates implements UseCase<List<RateRow>, NoParams> {
  final SettingsRepository repository;
  GetRates(this.repository);

  @override
  Future<Either<Failure, List<RateRow>>> call(NoParams params) =>
      repository.getRates();
}
