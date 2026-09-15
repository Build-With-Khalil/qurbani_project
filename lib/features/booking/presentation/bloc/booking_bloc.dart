import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../settings/domain/entities/rate.dart';
import '../../../settings/domain/usecases/get_rates.dart';
import '../../domain/entities/booking_draft.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/partial_cow.dart';
import '../../domain/usecases/create_booking.dart';
import '../../domain/usecases/search_customers.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingFlowState> {
  final CreateBooking createBooking;
  final SearchCustomers searchCustomers;
  final GetRates getRates;

  static const _uuid = Uuid();

  BookingBloc({
    required this.createBooking,
    required this.searchCustomers,
    required this.getRates,
  }) : super(const BookingFlowState()) {
    on<BookingInitRequested>(_onInit);
    on<BookingTypeChanged>(_onType);
    on<BookingDayChanged>(_onDay);
    on<BookingHissaCountChanged>((e, emit) =>
        emit(state.copyWith(draft: state.draft.copyWith(hissaCount: e.count))));
    on<BookingQtyChanged>((e, emit) =>
        emit(state.copyWith(draft: state.draft.copyWith(quantity: e.qty))));
    on<BookingCowChanged>((e, emit) {
      if (e.cowTag == null) {
        emit(state.copyWith(
            draft: state.draft.copyWith(clearCowTag: true)));
      } else {
        emit(state.copyWith(draft: state.draft.copyWith(cowTag: e.cowTag)));
      }
    });
    on<BookingCustomerChanged>((e, emit) =>
        emit(state.copyWith(draft: state.draft.copyWith(customer: e.customer))));
    on<BookingCustomerQueryChanged>(_onSearch);
    on<BookingConfirmRequested>(_onConfirm);
    on<BookingReset>((_, emit) => emit(const BookingFlowState()));
  }

  Future<void> _onInit(
      BookingInitRequested e, Emitter<BookingFlowState> emit) async {
    emit(state.copyWith(status: BookingStatus.loading));
    final ratesResult = await getRates(const NoParams());
    ratesResult.fold(
      (f) => emit(state.copyWith(
          status: BookingStatus.failure, errorMessage: f.message)),
      (rates) {
        final draft = state.draft.copyWith(
          rate: rates
              .firstWhere((r) => r.type == state.draft.type,
                  orElse: () => rates.first)
              .rateFor(state.draft.day),
        );
        emit(state.copyWith(
          status: BookingStatus.ready,
          rates: rates,
          draft: draft,
        ));
      },
    );
  }

  void _onType(BookingTypeChanged e, Emitter<BookingFlowState> emit) {
    final rate = state.rateFor(e.type, state.draft.day);
    emit(state.copyWith(
      draft: state.draft.copyWith(type: e.type, rate: rate, clearCowTag: true),
    ));
  }

  void _onDay(BookingDayChanged e, Emitter<BookingFlowState> emit) {
    final rate = state.rateFor(state.draft.type, e.day);
    emit(state.copyWith(
      draft: state.draft.copyWith(day: e.day, rate: rate),
    ));
  }

  Future<void> _onSearch(BookingCustomerQueryChanged e,
      Emitter<BookingFlowState> emit) async {
    final r = await searchCustomers(e.query);
    r.fold(
      (_) => null,
      (list) => emit(state.copyWith(customerResults: list)),
    );
  }

  Future<void> _onConfirm(
      BookingConfirmRequested e, Emitter<BookingFlowState> emit) async {
    var draft = state.draft;
    if (draft.customer == null) {
      emit(state.copyWith(
          status: BookingStatus.failure,
          errorMessage: 'Customer details required.'));
      return;
    }
    // Ensure customer has an ID
    if (draft.customer!.id.isEmpty) {
      draft = draft.copyWith(
        customer: Customer(
          id: _uuid.v4(),
          name: draft.customer!.name,
          mobile: draft.customer!.mobile,
          address: draft.customer!.address,
          cnic: draft.customer!.cnic,
          note: draft.customer!.note,
        ),
      );
    }
    emit(state.copyWith(status: BookingStatus.submitting, draft: draft));
    final result = await createBooking(draft);
    result.fold(
      (f) => emit(state.copyWith(
          status: BookingStatus.failure, errorMessage: f.message)),
      (r) => emit(state.copyWith(
        status: BookingStatus.success,
        receiptId: r.receiptId,
      )),
    );
  }
}
