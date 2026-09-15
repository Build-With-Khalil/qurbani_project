import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/season_summary.dart';

abstract class ReportsRepository {
  Future<Either<Failure, SeasonSummary>> getSeasonSummary();
}
