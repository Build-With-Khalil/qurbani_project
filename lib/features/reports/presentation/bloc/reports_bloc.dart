import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/season_summary.dart';
import '../../domain/usecases/get_season_summary.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetSeasonSummary getSummary;

  ReportsBloc({required this.getSummary}) : super(const ReportsState()) {
    on<ReportsLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
      ReportsLoadRequested e, Emitter<ReportsState> emit) async {
    emit(state.copyWith(status: ReportsStatus.loading));
    final r = await getSummary(const NoParams());
    r.fold(
      (f) => emit(state.copyWith(
          status: ReportsStatus.failure, errorMessage: f.message)),
      (summary) =>
          emit(state.copyWith(status: ReportsStatus.ready, summary: summary)),
    );
  }
}
