import 'package:equatable/equatable.dart';

class PartialCow extends Equatable {
  final String tag;
  final String weight;
  final int filled;
  const PartialCow({
    required this.tag,
    required this.weight,
    required this.filled,
  });

  int get vacant => 7 - filled;

  @override
  List<Object?> get props => [tag, weight, filled];
}
