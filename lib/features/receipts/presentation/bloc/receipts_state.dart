part of 'receipts_bloc.dart';

enum ReceiptsStatus { initial, loading, ready, failure }

class ReceiptsState extends Equatable {
  final ReceiptsStatus status;
  final List<Receipt> all;
  final String query;
  final String filter;
  final ReceiptBundle? selected;
  final String? errorMessage;

  const ReceiptsState({
    this.status = ReceiptsStatus.initial,
    this.all = const [],
    this.query = '',
    this.filter = 'All days',
    this.selected,
    this.errorMessage,
  });

  List<Receipt> get visible {
    final q = query.trim().toLowerCase();
    var list = all;
    if (filter != 'All days') {
      if (filter.startsWith('Day ')) {
        final d = int.tryParse(filter.split(' ').last);
        if (d != null) list = list.where((r) => r.day == d).toList();
      } else if (filter == 'Gaay') {
        list = list.where((r) => r.animalType == AnimalType.gaay).toList();
      } else if (filter == 'Bakra') {
        list = list.where((r) => r.animalType == AnimalType.bakra).toList();
      }
    }
    if (q.isEmpty) return list;
    return list
        .where((r) =>
            r.id.toLowerCase().contains(q) ||
            r.customerName.toLowerCase().contains(q) ||
            (r.customerPhone?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  ReceiptsState copyWith({
    ReceiptsStatus? status,
    List<Receipt>? all,
    String? query,
    String? filter,
    ReceiptBundle? selected,
    String? errorMessage,
  }) =>
      ReceiptsState(
        status: status ?? this.status,
        all: all ?? this.all,
        query: query ?? this.query,
        filter: filter ?? this.filter,
        selected: selected ?? this.selected,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, all, query, filter, selected, errorMessage];
}
