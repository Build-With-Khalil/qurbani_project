import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/org_settings.dart';
import '../../domain/entities/rate.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource remote;
  SettingsRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, OrgSettings>> getOrgSettings() async {
    try {
      return Right(await remote.getOrgSettings());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveOrgSettings(OrgSettings settings) async {
    try {
      await remote.saveOrgSettings(settings);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RateRow>>> getRates() async {
    try {
      return Right(await remote.getRates());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveRates(List<RateRow> rates) async {
    try {
      await remote.saveRates(rates);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
