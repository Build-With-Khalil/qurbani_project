import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

class GetExpenses implements UseCase<List<Expense>, NoParams> {
  final ExpensesRepository repository;
  GetExpenses(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(NoParams params) =>
      repository.getExpenses();
}
