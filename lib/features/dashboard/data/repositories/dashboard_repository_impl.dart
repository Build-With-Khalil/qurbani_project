import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource remote;
  DashboardRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, DashboardSummary>> getSummary() async {
    try {
      return Right(await remote.getSummary());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
