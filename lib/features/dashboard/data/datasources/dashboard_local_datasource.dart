import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/dashboard_summary.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardSummary> getSummary();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final SupabaseClient client;
  DashboardLocalDataSourceImpl({required this.client});

  String _uid() {
    final id = client.auth.currentUser?.id;
    if (id == null) {
      throw UnauthorizedException('No active session.');
    }
    return id;
  }

  @override
  Future<DashboardSummary> getSummary() async {
    final uid = _uid();

    final receiptsRaw = await client
        .from('receipts')
        .select('amount, created_at')
        .eq('user_id', uid);
    final receipts = (receiptsRaw as List).cast<Map<String, dynamic>>();

    final expensesRaw = await client
        .from('expenses')
        .select('amount')
        .eq('user_id', uid);
    final expenses = (expensesRaw as List).cast<Map<String, dynamic>>();

    final animalsRaw = await client
        .from('animals')
        .select('tag, type')
        .eq('user_id', uid);
    final animals = (animalsRaw as List).cast<Map<String, dynamic>>();

    final slotsRaw = await client
        .from('hissa_slots')
        .select('animal_tag, name')
        .eq('user_id', uid);
    final slots = (slotsRaw as List).cast<Map<String, dynamic>>();

    num income = 0;
    for (final r in receipts) {
      income += (r['amount'] as num? ?? 0);
    }
    num expense = 0;
    for (final e in expenses) {
      expense += (e['amount'] as num? ?? 0);
    }

    final today = DateTime.now();
    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    num todayIncome = 0;
    int todayReceipts = 0;
    for (final r in receipts) {
      final ts =
          DateTime.tryParse(r['created_at'] as String? ?? '')?.toLocal() ??
              DateTime.now();
      if (sameDay(ts, today)) {
        todayIncome += (r['amount'] as num? ?? 0);
        todayReceipts++;
      }
    }

    // Aggregate hissa slots per cow tag
    final slotsByTag = <String, List<String>>{};
    for (final s in slots) {
      final tag = s['animal_tag'] as String;
      slotsByTag
          .putIfAbsent(tag, () => [])
          .add(s['name'] as String? ?? '');
    }

    final cows = animals.where((a) => a['type'] == 'gaay').toList();
    final gaayTotal = cows.length;
    int complete = 0;
    int partial = 0;
    final partials = <PartialCowSummary>[];
    for (final c in cows) {
      final tag = c['tag'] as String;
      final names = slotsByTag[tag] ?? const <String>[];
      final filled = names.length;
      if (filled >= 7) {
        complete++;
      } else if (filled > 0) {
        partial++;
        final preview = names.length <= 2
            ? names.join(', ')
            : '${names.first}, +${names.length - 1}';
        partials.add(PartialCowSummary(
          tag: tag,
          filled: filled,
          ownersPreview: preview,
        ));
      }
    }

    int bakraBooked = 0;
    for (final a in animals) {
      if (a['type'] != 'gaay') bakraBooked++;
    }

    return DashboardSummary(
      income: income,
      expense: expense,
      bookings: receipts.length,
      netBalance: income - expense,
      todayIncome: todayIncome,
      todayReceipts: todayReceipts,
      gaayComplete: complete,
      gaayTotal: gaayTotal,
      gaayPartial: partial,
      bakraBooked: bakraBooked,
      partialCows: partials.take(3).toList(),
      seasonStart: DateTime(today.year, 6, 28),
    );
  }
}
