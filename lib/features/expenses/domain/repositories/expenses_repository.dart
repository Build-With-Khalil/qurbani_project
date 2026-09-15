import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';

abstract class ExpensesRepository {
  Future<Either<Failure, List<Expense>>> getExpenses();
  Future<Either<Failure, void>> saveExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String id);
}
