import 'package:equatable/equatable.dart';

import '../../../settings/domain/entities/rate.dart';
import 'customer.dart';

class BookingDraft extends Equatable {
  final AnimalType type;
  final int day;
  final int rate;
  final int hissaCount; // For Gaay (1..7), for others ignored
  final int quantity; // For non-Gaay (1+), for Gaay ignored
  final String? cowTag; // null = new cow, else existing tag
  final Customer? customer;

  const BookingDraft({
    this.type = AnimalType.gaay,
    this.day = 1,
    this.rate = 0,
    this.hissaCount = 1,
    this.quantity = 1,
    this.cowTag,
    this.customer,
  });

  BookingDraft copyWith({
    AnimalType? type,
    int? day,
    int? rate,
    int? hissaCount,
    int? quantity,
    String? cowTag,
    bool clearCowTag = false,
    Customer? customer,
  }) =>
      BookingDraft(
        type: type ?? this.type,
        day: day ?? this.day,
        rate: rate ?? this.rate,
        hissaCount: hissaCount ?? this.hissaCount,
        quantity: quantity ?? this.quantity,
        cowTag: clearCowTag ? null : (cowTag ?? this.cowTag),
        customer: customer ?? this.customer,
      );

  int get total => type == AnimalType.gaay
      ? rate * hissaCount
      : rate * quantity;

  @override
  List<Object?> get props =>
      [type, day, rate, hissaCount, quantity, cowTag, customer];
}
