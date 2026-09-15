import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipts_repository.dart';
import '../datasources/receipts_local_datasource.dart';

class ReceiptsRepositoryImpl implements ReceiptsRepository {
  final ReceiptsLocalDataSource remote;
  ReceiptsRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Receipt>>> getReceipts() async {
    try {
      return Right(await remote.getReceipts());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReceiptBundle>> getReceipt(String id) async {
    try {
      return Right(await remote.getReceipt(id));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
