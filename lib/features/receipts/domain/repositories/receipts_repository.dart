import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../animals/domain/entities/animal.dart';
import '../../../settings/domain/entities/org_settings.dart';
import '../entities/receipt.dart';

class ReceiptBundle {
  final Receipt receipt;
  final Animal? animal;
  final OrgSettings org;
  ReceiptBundle({
    required this.receipt,
    required this.animal,
    required this.org,
  });
}

abstract class ReceiptsRepository {
  Future<Either<Failure, List<Receipt>>> getReceipts();
  Future<Either<Failure, ReceiptBundle>> getReceipt(String id);
}
