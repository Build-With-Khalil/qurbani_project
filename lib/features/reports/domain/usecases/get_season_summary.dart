import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/season_summary.dart';
import '../repositories/reports_repository.dart';

class GetSeasonSummary implements UseCase<SeasonSummary, NoParams> {
  final ReportsRepository repository;
  GetSeasonSummary(this.repository);

  @override
  Future<Either<Failure, SeasonSummary>> call(NoParams params) =>
      repository.getSeasonSummary();
}
