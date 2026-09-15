import 'package:equatable/equatable.dart';

enum AnimalType { gaay, bakra, dunba, sheep }

extension AnimalTypeX on AnimalType {
  String get label => switch (this) {
        AnimalType.gaay => 'Gaay',
        AnimalType.bakra => 'Bakra',
        AnimalType.dunba => 'Dunba',
        AnimalType.sheep => 'Sheep',
      };

  String get unitLabel => switch (this) {
        AnimalType.gaay => 'per hissa',
        _ => 'per janwar',
      };
}

class RateRow extends Equatable {
  final AnimalType type;
  final List<int> dayRates;

  const RateRow({required this.type, required this.dayRates});

  int rateFor(int day) => dayRates[(day - 1).clamp(0, dayRates.length - 1)];

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'dayRates': dayRates,
      };

  factory RateRow.fromMap(Map<dynamic, dynamic> m) => RateRow(
        type: AnimalType.values.firstWhere((t) => t.name == m['type']),
        dayRates:
            (m['dayRates'] as List).map((e) => (e as num).toInt()).toList(),
      );

  static const List<RateRow> seed = [
    RateRow(type: AnimalType.gaay, dayRates: [18000, 19000, 21000]),
    RateRow(type: AnimalType.bakra, dayRates: [42000, 44000, 47000]),
    RateRow(type: AnimalType.dunba, dayRates: [55000, 58000, 62000]),
    RateRow(type: AnimalType.sheep, dayRates: [38000, 40000, 43000]),
  ];

  @override
  List<Object?> get props => [type, dayRates];
}
