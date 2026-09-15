import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../settings/domain/entities/rate.dart';
import '../../domain/entities/booking_draft.dart';
import '../../domain/entities/booking_result.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/partial_cow.dart';

abstract class BookingLocalDataSource {
  Future<BookingResult> createBooking(BookingDraft draft);
  Future<List<Customer>> searchCustomers(String query);
  Future<List<PartialCow>> getPartialCows();
}

class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  final SupabaseClient client;

  static const _uuid = Uuid();

  BookingLocalDataSourceImpl({required this.client});

  String _uid() {
    final id = client.auth.currentUser?.id;
    if (id == null) {
      throw UnauthorizedException('No active session.');
    }
    return id;
  }

  @override
  Future<BookingResult> createBooking(BookingDraft draft) async {
    final customer = draft.customer;
    if (customer == null) {
      throw ValidationException('Customer details required.');
    }
    final uid = _uid();

    // 1. Upsert customer
    await client.from('customers').upsert({
      'user_id': uid,
      'id': customer.id,
      'name': customer.name,
      'mobile': customer.mobile,
      'address': customer.address,
      'cnic': customer.cnic,
      'note': customer.note,
    }, onConflict: 'user_id,id');

    // 2. Resolve / create animal
    String animalTag;
    if (draft.type == AnimalType.gaay) {
      Map<String, dynamic>? animal;
      if (draft.cowTag != null) {
        animal = await client
            .from('animals')
            .select()
            .eq('user_id', uid)
            .eq('tag', draft.cowTag!)
            .maybeSingle();
      }
      if (animal == null) {
        animalTag = await _nextTagFor(uid, AnimalType.gaay);
        await client.from('animals').insert({
          'user_id': uid,
          'tag': animalTag,
          'type': 'gaay',
          'weight': '410 kg',
          'day': draft.day,
          'rate': draft.rate,
          'quantity': 0,
        });
      } else {
        animalTag = animal['tag'] as String;
      }
      final filledRows = await client
          .from('hissa_slots')
          .select('id')
          .eq('user_id', uid)
          .eq('animal_tag', animalTag);
      final filled = (filledRows as List).length;
      if (filled + draft.hissaCount > 7) {
        throw ValidationException('Not enough vacant hissay.');
      }
    } else {
      animalTag = await _nextTagFor(uid, draft.type);
      await client.from('animals').insert({
        'user_id': uid,
        'tag': animalTag,
        'type': draft.type.name,
        'weight': '',
        'day': draft.day,
        'rate': draft.rate,
        'quantity': draft.quantity,
      });
    }

    // 3. Receipt + booking ids
    final receiptId = await _nextReceiptId(uid);
    final bookingId = _uuid.v4();
    final nowIso = DateTime.now().toUtc().toIso8601String();

    await client.from('receipts').insert({
      'user_id': uid,
      'id': receiptId,
      'booking_id': bookingId,
      'customer_id': customer.id,
      'customer_name': customer.name,
      'animal_tag': animalTag,
      'animal_type': draft.type.name,
      'day': draft.day,
      'rate': draft.rate,
      'hissa_count': draft.type == AnimalType.gaay ? draft.hissaCount : null,
      'quantity': draft.type == AnimalType.gaay ? null : draft.quantity,
      'amount': draft.total,
      'created_at': nowIso,
    });

    if (draft.type == AnimalType.gaay) {
      final rows = <Map<String, dynamic>>[
        for (int i = 0; i < draft.hissaCount; i++)
          {
            'user_id': uid,
            'animal_tag': animalTag,
            'name': customer.name,
            'customer_id': customer.id,
            'amount': draft.rate,
            'receipt_id': receiptId,
          }
      ];
      await client.from('hissa_slots').insert(rows);
    }

    await client.from('bookings').insert({
      'id': bookingId,
      'user_id': uid,
      'customer_id': customer.id,
      'animal_tag': animalTag,
      'type': draft.type.name,
      'day': draft.day,
      'rate': draft.rate,
      'amount': draft.total,
      'receipt_id': receiptId,
      'created_at': nowIso,
    });

    return BookingResult(receiptId: receiptId, bookingId: bookingId);
  }

  Future<String> _nextTagFor(String uid, AnimalType t) async {
    final prefix = switch (t) {
      AnimalType.bakra => 'BAK',
      AnimalType.dunba => 'DUN',
      AnimalType.sheep => 'SHP',
      AnimalType.gaay => 'COW',
    };
    final rows = await client
        .from('animals')
        .select('tag')
        .eq('user_id', uid)
        .like('tag', '$prefix-%');
    final tags = (rows as List).map((r) => r['tag'] as String);
    final maxN = tags.fold<int>(0, (acc, tag) {
      final n = int.tryParse(tag.replaceAll('$prefix-', '')) ?? 0;
      return n > acc ? n : acc;
    });
    return '$prefix-${(maxN + 1).toString().padLeft(2, '0')}';
  }

  Future<String> _nextReceiptId(String uid) async {
    final rows = await client
        .from('receipts')
        .select('id')
        .eq('user_id', uid)
        .like('id', 'R-%');
    final ids = (rows as List).map((r) => r['id'] as String);
    final maxN = ids.fold<int>(0, (acc, id) {
      final n = int.tryParse(id.replaceAll('R-', '')) ?? 0;
      return n > acc ? n : acc;
    });
    return 'R-${(maxN + 1 + 1040).toString()}';
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final uid = _uid();
    final q = query.trim();
    var builder = client.from('customers').select().eq('user_id', uid);
    if (q.isNotEmpty) {
      builder = builder.or('name.ilike.%$q%,mobile.ilike.%$q%');
    }
    final rows = await builder.limit(20);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map((m) => Customer(
              id: m['id'] as String,
              name: m['name'] as String,
              mobile: m['mobile'] as String,
              address: m['address'] as String?,
              cnic: m['cnic'] as String?,
              note: m['note'] as String?,
            ))
        .toList();
  }

  @override
  Future<List<PartialCow>> getPartialCows() async {
    final uid = _uid();
    final cows = await client
        .from('animals')
        .select('tag, weight')
        .eq('user_id', uid)
        .eq('type', 'gaay');
    final cowList = (cows as List).cast<Map<String, dynamic>>();
    if (cowList.isEmpty) return [];

    final slots = await client
        .from('hissa_slots')
        .select('animal_tag')
        .eq('user_id', uid);
    final counts = <String, int>{};
    for (final s in (slots as List).cast<Map<String, dynamic>>()) {
      final tag = s['animal_tag'] as String;
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
    final partials = <PartialCow>[];
    for (final c in cowList) {
      final tag = c['tag'] as String;
      final filled = counts[tag] ?? 0;
      if (filled > 0 && filled < 7) {
        partials.add(PartialCow(
          tag: tag,
          weight: c['weight'] as String? ?? '',
          filled: filled,
        ));
      }
    }
    return partials;
  }
}
