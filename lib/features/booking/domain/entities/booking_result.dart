import 'package:equatable/equatable.dart';

class BookingResult extends Equatable {
  final String receiptId;
  final String bookingId;
  const BookingResult({required this.receiptId, required this.bookingId});

  @override
  List<Object?> get props => [receiptId, bookingId];
}
