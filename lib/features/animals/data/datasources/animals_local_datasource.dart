import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../settings/domain/entities/rate.dart';
import '../../domain/entities/animal.dart';

abstract class AnimalsLocalDataSource {
  Future<List<Animal>> getAnimals();
  Future<Animal?> getAnimal(String tag);
}

class AnimalsLocalDataSourceImpl implements AnimalsLocalDataSource {
  final SupabaseClient client;
  AnimalsLocalDataSourceImpl({required this.client});

  String _uid() {
    final id = client.auth.currentUser?.id;
    if (id == null) {
      throw UnauthorizedException('No active session.');
    }
    return id;
  }

  @override
  Future<List<Animal>> getAnimals() async {
    final uid = _uid();
    final rows = await client
        .from('animals')
        .select()
        .eq('user_id', uid)
        .order('tag');
    final animals = (rows as List).cast<Map<String, dynamic>>();
    if (animals.isEmpty) return [];

    final slotRows = await client
        .from('hissa_slots')
        .select()
        .eq('user_id', uid);
    final slotsByTag = <String, List<HissaSlotEntity>>{};
    for (final s in (slotRows as List).cast<Map<String, dynamic>>()) {
      final tag = s['animal_tag'] as String;
      slotsByTag.putIfAbsent(tag, () => []).add(HissaSlotEntity(
            name: s['name'] as String,
            customerId: s['customer_id'] as String? ?? '',
            amount: s['amount'] as num,
            receiptId: s['receipt_id'] as String,
          ));
    }

    return animals
        .map((m) => _animalFromRow(m, slotsByTag[m['tag']] ?? const []))
        .toList();
  }

  @override
  Future<Animal?> getAnimal(String tag) async {
    final uid = _uid();
    final row = await client
        .from('animals')
        .select()
        .eq('user_id', uid)
        .eq('tag', tag)
        .maybeSingle();
    if (row == null) return null;
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
    return _animalFromRow(row, hissay);
  }

  Animal _animalFromRow(
    Map<String, dynamic> m,
    List<HissaSlotEntity> hissay,
  ) =>
      Animal(
        tag: m['tag'] as String,
        type: AnimalType.values.firstWhere((t) => t.name == m['type']),
        weight: m['weight'] as String? ?? '',
        day: (m['day'] as num? ?? 1).toInt(),
        rate: (m['rate'] as num? ?? 0),
        hissay: hissay,
        quantity: (m['quantity'] as num? ?? 0).toInt(),
      );
}
