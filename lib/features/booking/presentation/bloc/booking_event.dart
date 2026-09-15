part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class BookingInitRequested extends BookingEvent {
  const BookingInitRequested();
}

class BookingTypeChanged extends BookingEvent {
  final AnimalType type;
  const BookingTypeChanged(this.type);
  @override
  List<Object?> get props => [type];
}

class BookingDayChanged extends BookingEvent {
  final int day;
  const BookingDayChanged(this.day);
  @override
  List<Object?> get props => [day];
}

class BookingHissaCountChanged extends BookingEvent {
  final int count;
  const BookingHissaCountChanged(this.count);
  @override
  List<Object?> get props => [count];
}

class BookingQtyChanged extends BookingEvent {
  final int qty;
  const BookingQtyChanged(this.qty);
  @override
  List<Object?> get props => [qty];
}

class BookingCowChanged extends BookingEvent {
  final String? cowTag;
  const BookingCowChanged(this.cowTag);
  @override
  List<Object?> get props => [cowTag];
}

class BookingCustomerChanged extends BookingEvent {
  final Customer customer;
  const BookingCustomerChanged(this.customer);
  @override
  List<Object?> get props => [customer];
}

class BookingCustomerQueryChanged extends BookingEvent {
  final String query;
  const BookingCustomerQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class BookingConfirmRequested extends BookingEvent {
  const BookingConfirmRequested();
}

class BookingReset extends BookingEvent {
  const BookingReset();
}
