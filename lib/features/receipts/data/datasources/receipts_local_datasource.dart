import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../animals/domain/entities/animal.dart';
import '../../../settings/domain/entities/org_settings.dart';
import '../../../settings/domain/entities/rate.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipts_repository.dart';

abstract class ReceiptsLocalDataSource {
  Future<List<Receipt>> getReceipts();
  Future<ReceiptBundle> getReceipt(String id);
}

class ReceiptsLocalDataSourceImpl implements ReceiptsLocalDataSource {
  final SupabaseClient client;
  ReceiptsLocalDataSourceImpl({required this.client});

  String _uid() {
    final id = client.auth.currentUser?.id;
    if (id == null) {
      throw UnauthorizedException('No active session.');
    }
    return id;
  }

  @override
  Future<List<Receipt>> getReceipts() async {
    final uid = _uid();
    final rows = await client
        .from('receipts')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    final receipts = (rows as List).cast<Map<String, dynamic>>();
    if (receipts.isEmpty) return [];

    final customerIds = receipts
        .map((r) => r['customer_id'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    Map<String, Map<String, dynamic>> customersById = {};
    if (customerIds.isNotEmpty) {
      final custRows = await client
          .from('customers')
          .select()
          .eq('user_id', uid)
          .inFilter('id', customerIds);
      customersById = {
        for (final c in (custRows as List).cast<Map<String, dynamic>>())
          c['id'] as String: c,
      };
    }

    return receipts.map((m) {
      final cust = customersById[m['customer_id']];
      return _receiptFromRow(m, customer: cust);
    }).toList();
  }

  @override
  Future<ReceiptBundle> getReceipt(String id) async {
    final uid = _uid();
    final row = await client
        .from('receipts')
        .select()
        .eq('user_id', uid)
        .eq('id', id)
        .maybeSingle();
    if (row == null) {
      throw CacheException('Receipt $id not found.');
    }
    Map<String, dynamic>? customer;
    final cid = row['customer_id'] as String?;
    if (cid != null && cid.isNotEmpty) {
      customer = await client
          .from('customers')
          .select()
          .eq('user_id', uid)
          .eq('id', cid)
          .maybeSingle();
    }
    final receipt = _receiptFromRow(row, customer: customer);

    Animal? animal;
    final tag = row['animal_tag'] as String?;
    if (tag != null) {
      final aRow = await client
          .from('animals')
          .select()
          .eq('user_id', uid)
          .eq('tag', tag)
          .maybeSingle();
      if (aRow != null) {
        final slots = await client
            .from('hissa_slots')
            .select()
            .eq('user_id', uid)
            .eq('animal_tag', tag);
        final hissay = (slots as List)
            .cast<Map<String, dynamic>>()
            .map((s) => HissaSlotEntity(
                  name: s['name'] as String,
                  customerId: s['customer_id'] as String? ?? '',
                  amount: s['amount'] as num,
                  receiptId: s['receipt_id'] as String,
                ))
            .toList();
        animal = Animal(
          tag: aRow['tag'] as String,
          type:
              AnimalType.values.firstWhere((t) => t.name == aRow['type']),
          weight: aRow['weight'] as String? ?? '',
          day: (aRow['day'] as num? ?? 1).toInt(),
          rate: (aRow['rate'] as num? ?? 0),
          hissay: hissay,
          quantity: (aRow['quantity'] as num? ?? 0).toInt(),
        );
      }
    }

    final orgRow = await client
        .from('org_settings')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    final org = orgRow == null
        ? OrgSettings.seed
        : OrgSettings(
            name: orgRow['name'] as String,
            address: orgRow['address'] as String,
            contact: orgRow['contact'] as String,
            ntn: orgRow['ntn'] as String?,
            footerUrdu: orgRow['footer_urdu'] as String,
            footerEnglish: orgRow['footer_english'] as String,
            watermarkOnPdf: orgRow['watermark_on_pdf'] as bool? ?? true,
          );

    return ReceiptBundle(receipt: receipt, animal: animal, org: org);
  }

  Receipt _receiptFromRow(
    Map<String, dynamic> m, {
    Map<String, dynamic>? customer,
  }) =>
      Receipt(
        id: m['id'] as String,
        customerName: m['customer_name'] as String? ??
            (customer?['name'] as String? ?? '—'),
        customerId: m['customer_id'] as String? ?? '',
        customerPhone: customer?['mobile'] as String?,
        customerAddress: customer?['address'] as String?,
        animalTag: m['animal_tag'] as String? ?? '',
        animalType: AnimalType.values
            .firstWhere((t) => t.name == m['animal_type']),
        day: (m['day'] as num).toInt(),
        rate: m['rate'] as num,
        hissaCount: (m['hissa_count'] as num?)?.toInt(),
        quantity: (m['quantity'] as num?)?.toInt(),
        amount: m['amount'] as num,
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
