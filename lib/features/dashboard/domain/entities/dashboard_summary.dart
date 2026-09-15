import 'package:equatable/equatable.dart';

class PartialCowSummary extends Equatable {
  final String tag;
  final int filled;
  final String ownersPreview;
  const PartialCowSummary({
    required this.tag,
    required this.filled,
    required this.ownersPreview,
  });

  @override
  List<Object?> get props => [tag, filled, ownersPreview];
}

class DashboardSummary extends Equatable {
  final num income;
  final num expense;
  final int bookings;
  final num netBalance;
  final num todayIncome;
  final int todayReceipts;
  final int gaayComplete;
  final int gaayTotal;
  final int gaayPartial;
  final int bakraBooked;
  final List<PartialCowSummary> partialCows;
  final DateTime seasonStart;

  const DashboardSummary({
    required this.income,
    required this.expense,
    required this.bookings,
    required this.netBalance,
    required this.todayIncome,
    required this.todayReceipts,
    required this.gaayComplete,
    required this.gaayTotal,
    required this.gaayPartial,
    required this.bakraBooked,
    required this.partialCows,
    required this.seasonStart,
  });

  @override
  List<Object?> get props => [
        income,
        expense,
        bookings,
        netBalance,
        todayIncome,
        todayReceipts,
        gaayComplete,
        gaayTotal,
        gaayPartial,
        bakraBooked,
        partialCows,
        seasonStart,
      ];
}
