import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expenses_repository.dart';
import '../datasources/expenses_local_datasource.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesLocalDataSource remote;
  ExpensesRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Expense>>> getExpenses() async {
    try {
      return Right(await remote.getExpenses());
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveExpense(Expense expense) async {
    try {
      await remote.saveExpense(expense);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) async {
    try {
      await remote.deleteExpense(id);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
