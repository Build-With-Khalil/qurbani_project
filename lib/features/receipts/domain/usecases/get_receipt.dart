import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/receipts_repository.dart';

class GetReceipt implements UseCase<ReceiptBundle, String> {
  final ReceiptsRepository repository;
  GetReceipt(this.repository);

  @override
  Future<Either<Failure, ReceiptBundle>> call(String params) =>
      repository.getReceipt(params);
}
