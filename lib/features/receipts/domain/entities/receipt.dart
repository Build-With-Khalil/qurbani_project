import 'package:equatable/equatable.dart';

import '../../../settings/domain/entities/rate.dart';

class Receipt extends Equatable {
  final String id;
  final String customerName;
  final String customerId;
  final String? customerPhone;
  final String? customerAddress;
  final String animalTag;
  final AnimalType animalType;
  final int day;
  final num rate;
  final int? hissaCount;
  final int? quantity;
  final num amount;
  final DateTime createdAt;

  const Receipt({
    required this.id,
    required this.customerName,
    required this.customerId,
    this.customerPhone,
    this.customerAddress,
    required this.animalTag,
    required this.animalType,
    required this.day,
    required this.rate,
    this.hissaCount,
    this.quantity,
    required this.amount,
    required this.createdAt,
  });

  String get typeDesc => animalType == AnimalType.gaay
      ? 'Gaay · ${hissaCount ?? 0} hissay'
      : '${animalType.label} · ${quantity ?? 0}';

  factory Receipt.fromMap(
    Map<dynamic, dynamic> m, {
    Map<dynamic, dynamic>? customer,
  }) =>
      Receipt(
        id: m['id'] as String,
        customerName: m['customerName'] as String? ??
            (customer?['name'] as String? ?? '—'),
        customerId: m['customerId'] as String? ?? '',
        customerPhone: customer?['mobile'] as String?,
        customerAddress: customer?['address'] as String?,
        animalTag: m['animalTag'] as String? ?? '',
        animalType: AnimalType.values
            .firstWhere((t) => t.name == m['animalType']),
        day: (m['day'] as num).toInt(),
        rate: m['rate'] as num,
        hissaCount: (m['hissaCount'] as num?)?.toInt(),
        quantity: (m['quantity'] as num?)?.toInt(),
        amount: m['amount'] as num,
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerId,
        customerPhone,
        customerAddress,
        animalTag,
        animalType,
        day,
        rate,
        hissaCount,
        quantity,
        amount,
        createdAt,
      ];
}
