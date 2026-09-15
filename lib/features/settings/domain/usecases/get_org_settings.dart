import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/org_settings.dart';
import '../repositories/settings_repository.dart';

class GetOrgSettings implements UseCase<OrgSettings, NoParams> {
  final SettingsRepository repository;
  GetOrgSettings(this.repository);

  @override
  Future<Either<Failure, OrgSettings>> call(NoParams params) =>
      repository.getOrgSettings();
}
