import 'package:equatable/equatable.dart';

enum ExpenseCategory { janwar, feed, transport, qasai, labour, packing, misc }

extension ExpenseCategoryX on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.janwar => 'Janwar',
        ExpenseCategory.feed => 'Feed',
        ExpenseCategory.transport => 'Transport',
        ExpenseCategory.qasai => 'Qasai',
        ExpenseCategory.labour => 'Labour',
        ExpenseCategory.packing => 'Packing',
        ExpenseCategory.misc => 'Misc',
      };

  String get emoji => switch (this) {
        ExpenseCategory.janwar => '🐄',
        ExpenseCategory.feed => '🌾',
        ExpenseCategory.transport => '🚚',
        ExpenseCategory.qasai => '⚒︎',
        ExpenseCategory.labour => '🧑‍🌾',
        ExpenseCategory.packing => '📦',
        ExpenseCategory.misc => '➕',
      };
}

class Expense extends Equatable {
  final String id;
  final ExpenseCategory category;
  final num amount;
  final String description;
  final String? linkedAnimalTag;
  final DateTime date;

  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    this.linkedAnimalTag,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category.name,
        'amount': amount,
        'description': description,
        'linkedAnimalTag': linkedAnimalTag,
        'date': date.toIso8601String(),
      };

  factory Expense.fromMap(Map<dynamic, dynamic> m) => Expense(
        id: m['id'] as String,
        category: ExpenseCategory.values
            .firstWhere((c) => c.name == m['category']),
        amount: m['amount'] as num,
        description: m['description'] as String? ?? '',
        linkedAnimalTag: m['linkedAnimalTag'] as String?,
        date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
      );

  @override
  List<Object?> get props =>
      [id, category, amount, description, linkedAnimalTag, date];
}
