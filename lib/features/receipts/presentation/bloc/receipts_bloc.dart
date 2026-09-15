import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../settings/domain/entities/rate.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipts_repository.dart';
import '../../domain/usecases/get_receipt.dart';
import '../../domain/usecases/get_receipts.dart';

part 'receipts_event.dart';
part 'receipts_state.dart';

class ReceiptsBloc extends Bloc<ReceiptsEvent, ReceiptsState> {
  final GetReceipts getReceipts;
  final GetReceipt getReceipt;

  ReceiptsBloc({required this.getReceipts, required this.getReceipt})
      : super(const ReceiptsState()) {
    on<ReceiptsLoadRequested>(_onLoad);
    on<ReceiptsSearchChanged>((e, emit) =>
        emit(state.copyWith(query: e.query)));
    on<ReceiptsFilterChanged>(
        (e, emit) => emit(state.copyWith(filter: e.filter)));
    on<ReceiptDetailRequested>(_onDetail);
  }

  Future<void> _onLoad(
      ReceiptsLoadRequested e, Emitter<ReceiptsState> emit) async {
    emit(state.copyWith(status: ReceiptsStatus.loading));
    final r = await getReceipts(const NoParams());
    r.fold(
      (f) => emit(state.copyWith(
          status: ReceiptsStatus.failure, errorMessage: f.message)),
      (list) =>
          emit(state.copyWith(status: ReceiptsStatus.ready, all: list)),
    );
  }

  Future<void> _onDetail(
      ReceiptDetailRequested e, Emitter<ReceiptsState> emit) async {
    final r = await getReceipt(e.id);
    r.fold(
      (f) => emit(state.copyWith(
          status: ReceiptsStatus.failure, errorMessage: f.message)),
      (bundle) => emit(state.copyWith(selected: bundle)),
    );
  }
}
