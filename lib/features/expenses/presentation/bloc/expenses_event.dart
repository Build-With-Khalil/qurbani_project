part of 'expenses_bloc.dart';

abstract class ExpensesEvent extends Equatable {
  const ExpensesEvent();
  @override
  List<Object?> get props => [];
}

class ExpensesLoadRequested extends ExpensesEvent {
  const ExpensesLoadRequested();
}

class ExpenseSaved extends ExpensesEvent {
  final Expense expense;
  const ExpenseSaved(this.expense);
  @override
  List<Object?> get props => [expense];
}
