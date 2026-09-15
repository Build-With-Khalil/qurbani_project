import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/save_expense.dart';

part 'expenses_event.dart';
part 'expenses_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final GetExpenses getExpenses;
  final SaveExpense saveExpense;

  ExpensesBloc({required this.getExpenses, required this.saveExpense})
      : super(const ExpensesState()) {
    on<ExpensesLoadRequested>(_onLoad);
    on<ExpenseSaved>(_onSave);
  }

  Future<void> _onLoad(
      ExpensesLoadRequested e, Emitter<ExpensesState> emit) async {
    emit(state.copyWith(status: ExpensesStatus.loading));
    final r = await getExpenses(const NoParams());
    r.fold(
      (f) => emit(state.copyWith(
          status: ExpensesStatus.failure, errorMessage: f.message)),
      (list) =>
          emit(state.copyWith(status: ExpensesStatus.ready, all: list)),
    );
  }

  Future<void> _onSave(ExpenseSaved e, Emitter<ExpensesState> emit) async {
    emit(state.copyWith(status: ExpensesStatus.saving));
    final r = await saveExpense(e.expense);
    await r.fold(
      (f) async => emit(state.copyWith(
          status: ExpensesStatus.failure, errorMessage: f.message)),
      (_) async {
        final reload = await getExpenses(const NoParams());
        reload.fold(
          (f) => emit(state.copyWith(
              status: ExpensesStatus.failure, errorMessage: f.message)),
          (list) =>
              emit(state.copyWith(status: ExpensesStatus.saved, all: list)),
        );
      },
    );
  }
}
