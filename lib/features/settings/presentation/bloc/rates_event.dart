part of 'rates_bloc.dart';

abstract class RatesEvent extends Equatable {
  const RatesEvent();
  @override
  List<Object?> get props => [];
}

class RatesLoadRequested extends RatesEvent {
  const RatesLoadRequested();
}

class RateCellEdited extends RatesEvent {
  final AnimalType type;
  final int day;
  final int value;
  const RateCellEdited({required this.type, required this.day, required this.value});
  @override
  List<Object?> get props => [type, day, value];
}

class RatesSaveRequested extends RatesEvent {
  const RatesSaveRequested();
}
