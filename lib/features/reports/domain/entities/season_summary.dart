import 'package:equatable/equatable.dart';

class DayBar extends Equatable {
  final int day;
  final num income;
  final num expense;
  const DayBar({required this.day, required this.income, required this.expense});

  @override
  List<Object?> get props => [day, income, expense];
}

class TypeShare extends Equatable {
  final String label;
  final num amount;
  final double fraction;
  const TypeShare({
    required this.label,
    required this.amount,
    required this.fraction,
  });

  @override
  List<Object?> get props => [label, amount, fraction];
}

class AnimalTotal extends Equatable {
  final String label;
  final int count;
  const AnimalTotal({required this.label, required this.count});

  @override
  List<Object?> get props => [label, count];
}

class SeasonSummary extends Equatable {
  final num income;
  final num expense;
  final int bookings;
  final int customers;
  final int expenseEntries;
  final List<DayBar> dayBars;
  final List<TypeShare> byType;
  final List<AnimalTotal> animalTotals;

  const SeasonSummary({
    required this.income,
    required this.expense,
    required this.bookings,
    required this.customers,
    required this.expenseEntries,
    required this.dayBars,
    required this.byType,
    required this.animalTotals,
  });

  num get maxDayBar {
    num m = 0;
    for (final d in dayBars) {
      if (d.income > m) m = d.income;
      if (d.expense > m) m = d.expense;
    }
    return m;
  }

  @override
  List<Object?> get props =>
      [income, expense, bookings, customers, expenseEntries, dayBars, byType, animalTotals];
}
