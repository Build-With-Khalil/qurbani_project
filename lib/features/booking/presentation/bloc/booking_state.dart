part of 'booking_bloc.dart';

enum BookingStatus { initial, loading, ready, submitting, success, failure }

class BookingFlowState extends Equatable {
  final BookingStatus status;
  final BookingDraft draft;
  final List<RateRow> rates;
  final List<Customer> customerResults;
  final List<PartialCow> partialCows;
  final String? receiptId;
  final String? errorMessage;

  const BookingFlowState({
    this.status = BookingStatus.initial,
    this.draft = const BookingDraft(),
    this.rates = const [],
    this.customerResults = const [],
    this.partialCows = const [],
    this.receiptId,
    this.errorMessage,
  });

  int rateFor(AnimalType type, int day) {
    final row = rates.where((r) => r.type == type).firstOrNull;
    if (row == null) return 0;
    return row.rateFor(day);
  }

  BookingFlowState copyWith({
    BookingStatus? status,
    BookingDraft? draft,
    List<RateRow>? rates,
    List<Customer>? customerResults,
    List<PartialCow>? partialCows,
    String? receiptId,
    String? errorMessage,
  }) =>
      BookingFlowState(
        status: status ?? this.status,
        draft: draft ?? this.draft,
        rates: rates ?? this.rates,
        customerResults: customerResults ?? this.customerResults,
        partialCows: partialCows ?? this.partialCows,
        receiptId: receiptId ?? this.receiptId,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        draft,
        rates,
        customerResults,
        partialCows,
        receiptId,
        errorMessage,
      ];
}
