part of 'rates_bloc.dart';

enum RatesStatus { initial, loading, ready, saving, saved, failure }

class RatesState extends Equatable {
  final RatesStatus status;
  final List<RateRow> rates;
  final bool dirty;
  final String? errorMessage;

  const RatesState({
    this.status = RatesStatus.initial,
    this.rates = const [],
    this.dirty = false,
    this.errorMessage,
  });

  RatesState copyWith({
    RatesStatus? status,
    List<RateRow>? rates,
    bool? dirty,
    String? errorMessage,
  }) =>
      RatesState(
        status: status ?? this.status,
        rates: rates ?? this.rates,
        dirty: dirty ?? this.dirty,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, rates, dirty, errorMessage];
}
