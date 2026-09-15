import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/expense.dart';
import '../repositories/expenses_repository.dart';

class SaveExpense implements UseCase<void, Expense> {
  final ExpensesRepository repository;
  SaveExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(Expense params) =>
      repository.saveExpense(params);
}
