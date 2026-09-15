import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rate.dart';
import '../repositories/settings_repository.dart';

class SaveRates implements UseCase<void, List<RateRow>> {
  final SettingsRepository repository;
  SaveRates(this.repository);

  @override
  Future<Either<Failure, void>> call(List<RateRow> params) =>
      repository.saveRates(params);
}
