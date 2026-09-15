import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/usecases/get_dashboard_summary.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummary getSummary;

  DashboardBloc({required this.getSummary}) : super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(DashboardEvent _, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    final result = await getSummary(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: failure.message,
      )),
      (summary) => emit(state.copyWith(
        status: DashboardStatus.success,
        summary: summary,
      )),
    );
  }
}
