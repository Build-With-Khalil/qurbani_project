import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../settings/domain/entities/rate.dart';
import '../../domain/entities/season_summary.dart';
import '../../domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final SupabaseClient client;

  ReportsRepositoryImpl({required this.client});

  String _uid() {
    final id = client.auth.currentUser?.id;
    if (id == null) {
      throw UnauthorizedException('No active session.');
    }
    return id;
  }

  @override
  Future<Either<Failure, SeasonSummary>> getSeasonSummary() async {
    try {
      final uid = _uid();

      final receiptsRaw = await client
          .from('receipts')
          .select('amount, day, animal_type, customer_id')
          .eq('user_id', uid);
      final receipts = (receiptsRaw as List).cast<Map<String, dynamic>>();

      final expensesRaw = await client
          .from('expenses')
          .select('amount')
          .eq('user_id', uid);
      final expenses = (expensesRaw as List).cast<Map<String, dynamic>>();

      final animalsRaw = await client
          .from('animals')
          .select('tag, type, quantity')
          .eq('user_id', uid);
      final animals = (animalsRaw as List).cast<Map<String, dynamic>>();

      final slotsRaw = await client
          .from('hissa_slots')
          .select('animal_tag')
          .eq('user_id', uid);
      final slots = (slotsRaw as List).cast<Map<String, dynamic>>();

      num income = 0;
      final dayIncome = <int, num>{1: 0, 2: 0, 3: 0};
      final typeAmount = <AnimalType, num>{};
      final customerIds = <String>{};

      for (final r in receipts) {
        final amount = r['amount'] as num? ?? 0;
        income += amount;
        final day = (r['day'] as num? ?? 1).toInt();
        dayIncome[day] = (dayIncome[day] ?? 0) + amount;
        final type = AnimalType.values.firstWhere(
          (t) => t.name == r['animal_type'],
          orElse: () => AnimalType.gaay,
        );
        typeAmount[type] = (typeAmount[type] ?? 0) + amount;
        final cid = r['customer_id'] as String?;
        if (cid != null && cid.isNotEmpty) customerIds.add(cid);
      }

      num expense = 0;
      final dayExpense = <int, num>{1: 0, 2: 0, 3: 0};
      for (final e in expenses) {
        final amount = e['amount'] as num? ?? 0;
        expense += amount;
        dayExpense[1] = (dayExpense[1] ?? 0) + amount;
      }

      final totalForShare = typeAmount.values.fold<num>(0, (a, v) => a + v);
      final byType = <TypeShare>[];
      for (final t in AnimalType.values) {
        final amount = typeAmount[t] ?? 0;
        if (amount == 0) continue;
        byType.add(TypeShare(
          label: t.label,
          amount: amount,
          fraction: totalForShare == 0 ? 0 : amount / totalForShare,
        ));
      }
      if (byType.isEmpty) {
        byType.add(const TypeShare(
            label: 'No bookings yet', amount: 0, fraction: 0));
      }

      // Animal totals — need hissa counts per cow.
      final slotsByTag = <String, int>{};
      for (final s in slots) {
        final tag = s['animal_tag'] as String;
        slotsByTag[tag] = (slotsByTag[tag] ?? 0) + 1;
      }

      int gaayComplete = 0;
      int gaayPartial = 0;
      int bakra = 0;
      int dunba = 0;
      for (final a in animals) {
        final type = a['type'] as String?;
        if (type == 'gaay') {
          final filled = slotsByTag[a['tag'] as String] ?? 0;
          if (filled >= 7) {
            gaayComplete++;
          } else if (filled > 0) {
            gaayPartial++;
          }
        } else if (type == 'bakra') {
          bakra += (a['quantity'] as num? ?? 1).toInt();
        } else if (type == 'dunba') {
          dunba += (a['quantity'] as num? ?? 1).toInt();
        }
      }

      final animalTotals = <AnimalTotal>[
        AnimalTotal(label: 'Gaay (complete)', count: gaayComplete),
        AnimalTotal(label: 'Gaay (partial)', count: gaayPartial),
        AnimalTotal(label: 'Bakra', count: bakra),
        AnimalTotal(label: 'Dunba', count: dunba),
      ];

      return Right(SeasonSummary(
        income: income,
        expense: expense,
        bookings: receipts.length,
        customers: customerIds.length,
        expenseEntries: expenses.length,
        dayBars: [
          for (final d in [1, 2, 3])
            DayBar(
              day: d,
              income: dayIncome[d] ?? 0,
              expense: dayExpense[d] ?? 0,
            ),
        ],
        byType: byType,
        animalTotals: animalTotals,
      ));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
