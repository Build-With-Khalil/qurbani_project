part of 'expenses_bloc.dart';

enum ExpensesStatus { initial, loading, ready, saving, saved, failure }

class ExpensesGroup extends Equatable {
  final String dayLabel;
  final List<Expense> items;
  const ExpensesGroup({required this.dayLabel, required this.items});

  @override
  List<Object?> get props => [dayLabel, items];
}

class ExpensesState extends Equatable {
  final ExpensesStatus status;
  final List<Expense> all;
  final String? errorMessage;

  const ExpensesState({
    this.status = ExpensesStatus.initial,
    this.all = const [],
    this.errorMessage,
  });

  num get total => all.fold<num>(0, (a, e) => a + e.amount);

  num totalForCategories(Iterable<ExpenseCategory> cats) =>
      all.where((e) => cats.contains(e.category)).fold<num>(0, (a, e) => a + e.amount);

  List<ExpensesGroup> get groups {
    final now = DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    final today = <Expense>[];
    final yesterday = <Expense>[];
    final older = <Expense>[];
    final y = now.subtract(const Duration(days: 1));
    for (final e in all) {
      if (sameDay(e.date, now)) {
        today.add(e);
      } else if (sameDay(e.date, y)) {
        yesterday.add(e);
      } else {
        older.add(e);
      }
    }
    final groups = <ExpensesGroup>[];
    if (today.isNotEmpty) {
      groups.add(ExpensesGroup(dayLabel: 'Today', items: today));
    }
    if (yesterday.isNotEmpty) {
      groups.add(ExpensesGroup(dayLabel: 'Yesterday', items: yesterday));
    }
    if (older.isNotEmpty) {
      groups.add(ExpensesGroup(dayLabel: 'Older', items: older));
    }
    return groups;
  }

  ExpensesState copyWith({
    ExpensesStatus? status,
    List<Expense>? all,
    String? errorMessage,
  }) =>
      ExpensesState(
        status: status ?? this.status,
        all: all ?? this.all,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, all, errorMessage];
}
