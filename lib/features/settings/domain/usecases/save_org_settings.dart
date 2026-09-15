import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/org_settings.dart';
import '../repositories/settings_repository.dart';

class SaveOrgSettings implements UseCase<void, OrgSettings> {
  final SettingsRepository repository;
  SaveOrgSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(OrgSettings params) =>
      repository.saveOrgSettings(params);
}
