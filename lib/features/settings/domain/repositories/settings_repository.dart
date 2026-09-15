import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/org_settings.dart';
import '../entities/rate.dart';

abstract class SettingsRepository {
  Future<Either<Failure, OrgSettings>> getOrgSettings();
  Future<Either<Failure, void>> saveOrgSettings(OrgSettings settings);
  Future<Either<Failure, List<RateRow>>> getRates();
  Future<Either<Failure, void>> saveRates(List<RateRow> rates);
}
