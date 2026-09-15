import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/expense.dart';

abstract class ExpensesLocalDataSource {
  Future<List<Expense>> getExpenses();
  Future<void> saveExpense(Expense e);
  Future<void> deleteExpense(String id);
}

class ExpensesLocalDataSourceImpl implements ExpensesLocalDataSource {
  final SupabaseClient client;
  static const _uuid = Uuid();

  ExpensesLocalDataSourceImpl({required this.client});

  String _uid() {
    final id = client.auth.currentUser?.id;
    if (id == null) {
      throw UnauthorizedException('No active session.');
    }
    return id;
  }

  bool _isUuid(String s) =>
      RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
          .hasMatch(s);

  @override
  Future<List<Expense>> getExpenses() async {
    final uid = _uid();
    final rows = await client
        .from('expenses')
        .select()
        .eq('user_id', uid)
        .order('date', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>().map((m) {
      return Expense(
        id: m['id'] as String,
        category: ExpenseCategory.values
            .firstWhere((c) => c.name == m['category']),
        amount: m['amount'] as num,
        description: m['description'] as String? ?? '',
        linkedAnimalTag: m['linked_animal_tag'] as String?,
        date: DateTime.tryParse(m['date'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<void> saveExpense(Expense e) async {
    final uid = _uid();
    final id = _isUuid(e.id) ? e.id : _uuid.v4();
    await client.from('expenses').upsert({
      'id': id,
      'user_id': uid,
      'category': e.category.name,
      'amount': e.amount,
      'description': e.description,
      'linked_animal_tag': e.linkedAnimalTag,
      'date': e.date.toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> deleteExpense(String id) async {
    final uid = _uid();
    await client
        .from('expenses')
        .delete()
        .eq('user_id', uid)
        .eq('id', id);
  }
}
