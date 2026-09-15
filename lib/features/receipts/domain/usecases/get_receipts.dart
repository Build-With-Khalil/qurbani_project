import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/receipt.dart';
import '../repositories/receipts_repository.dart';

class GetReceipts implements UseCase<List<Receipt>, NoParams> {
  final ReceiptsRepository repository;
  GetReceipts(this.repository);

  @override
  Future<Either<Failure, List<Receipt>>> call(NoParams params) =>
      repository.getReceipts();
}
