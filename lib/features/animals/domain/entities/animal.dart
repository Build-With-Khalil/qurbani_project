import 'package:equatable/equatable.dart';

import '../../../settings/domain/entities/rate.dart';

class HissaSlotEntity extends Equatable {
  final String name;
  final String customerId;
  final num amount;
  final String receiptId;
  const HissaSlotEntity({
    required this.name,
    required this.customerId,
    required this.amount,
    required this.receiptId,
  });

  factory HissaSlotEntity.fromMap(Map<dynamic, dynamic> m) => HissaSlotEntity(
        name: m['name'] as String,
        customerId: m['customerId'] as String? ?? '',
        amount: m['amount'] as num,
        receiptId: m['receiptId'] as String,
      );

  @override
  List<Object?> get props => [name, customerId, amount, receiptId];
}

class Animal extends Equatable {
  final String tag;
  final AnimalType type;
  final String weight;
  final int day;
  final num rate;
  final List<HissaSlotEntity> hissay;
  final int quantity;

  const Animal({
    required this.tag,
    required this.type,
    required this.weight,
    required this.day,
    required this.rate,
    this.hissay = const [],
    this.quantity = 0,
  });

  int get filled => hissay.length;
  int get vacant => 7 - filled;
  bool get isComplete => type == AnimalType.gaay && filled == 7;
  bool get isPartial => type == AnimalType.gaay && filled > 0 && filled < 7;
  bool get isEmpty => type == AnimalType.gaay && filled == 0;

  factory Animal.fromMap(Map<dynamic, dynamic> m) => Animal(
        tag: m['tag'] as String,
        type: AnimalType.values.firstWhere((t) => t.name == m['type']),
        weight: m['weight'] as String? ?? '',
        day: (m['day'] as num? ?? 1).toInt(),
        rate: (m['rate'] as num? ?? 0),
        hissay: ((m['hissay'] as List?) ?? [])
            .map((h) => HissaSlotEntity.fromMap(Map<dynamic, dynamic>.from(h as Map)))
            .toList(),
        quantity: (m['quantity'] as num? ?? 0).toInt(),
      );

  @override
  List<Object?> get props => [tag, type, weight, day, rate, hissay, quantity];
}
