import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/rate.dart';
import '../../domain/usecases/get_rates.dart';
import '../../domain/usecases/save_rates.dart';

part 'rates_event.dart';
part 'rates_state.dart';

class RatesBloc extends Bloc<RatesEvent, RatesState> {
  final GetRates getRates;
  final SaveRates saveRates;

  RatesBloc({required this.getRates, required this.saveRates})
      : super(const RatesState()) {
    on<RatesLoadRequested>(_onLoad);
    on<RateCellEdited>(_onEdit);
    on<RatesSaveRequested>(_onSave);
  }

  Future<void> _onLoad(RatesLoadRequested e, Emitter<RatesState> emit) async {
    emit(state.copyWith(status: RatesStatus.loading));
    final r = await getRates(const NoParams());
    r.fold(
      (f) => emit(state.copyWith(
          status: RatesStatus.failure, errorMessage: f.message)),
      (list) =>
          emit(state.copyWith(status: RatesStatus.ready, rates: list)),
    );
  }

  void _onEdit(RateCellEdited e, Emitter<RatesState> emit) {
    final list = [...state.rates];
    final idx = list.indexWhere((r) => r.type == e.type);
    if (idx < 0) return;
    final updatedDays = [...list[idx].dayRates];
    updatedDays[e.day - 1] = e.value;
    list[idx] = RateRow(type: e.type, dayRates: updatedDays);
    emit(state.copyWith(rates: list, dirty: true));
  }

  Future<void> _onSave(RatesSaveRequested e, Emitter<RatesState> emit) async {
    emit(state.copyWith(status: RatesStatus.saving));
    final r = await saveRates(state.rates);
    r.fold(
      (f) => emit(state.copyWith(
          status: RatesStatus.failure, errorMessage: f.message)),
      (_) =>
          emit(state.copyWith(status: RatesStatus.saved, dirty: false)),
    );
  }
}
