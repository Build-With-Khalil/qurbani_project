import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/org_settings.dart';
import '../../domain/entities/rate.dart';

abstract class SettingsLocalDataSource {
  Future<OrgSettings> getOrgSettings();
  Future<void> saveOrgSettings(OrgSettings settings);
  Future<List<RateRow>> getRates();
  Future<void> saveRates(List<RateRow> rates);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SupabaseClient client;
  SettingsLocalDataSourceImpl({required this.client});

  String _uid() {
    final id = client.auth.currentUser?.id;
    if (id == null) {
      throw UnauthorizedException('No active session.');
    }
    return id;
  }

  Map<String, dynamic> _orgToRow(String uid, OrgSettings s) => {
        'user_id': uid,
        'name': s.name,
        'address': s.address,
        'contact': s.contact,
        'ntn': s.ntn,
        'footer_urdu': s.footerUrdu,
        'footer_english': s.footerEnglish,
        'watermark_on_pdf': s.watermarkOnPdf,
      };

  OrgSettings _orgFromRow(Map<String, dynamic> m) => OrgSettings(
        name: m['name'] as String,
        address: m['address'] as String,
        contact: m['contact'] as String,
        ntn: m['ntn'] as String?,
        footerUrdu: m['footer_urdu'] as String,
        footerEnglish: m['footer_english'] as String,
        watermarkOnPdf: m['watermark_on_pdf'] as bool? ?? true,
      );

  @override
  Future<OrgSettings> getOrgSettings() async {
    final uid = _uid();
    final row = await client
        .from('org_settings')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    if (row == null) {
      await saveOrgSettings(OrgSettings.seed);
      return OrgSettings.seed;
    }
    return _orgFromRow(row);
  }

  @override
  Future<void> saveOrgSettings(OrgSettings settings) async {
    final uid = _uid();
    await client
        .from('org_settings')
        .upsert(_orgToRow(uid, settings), onConflict: 'user_id');
  }

  @override
  Future<List<RateRow>> getRates() async {
    final uid = _uid();
    final rows = await client.from('rates').select().eq('user_id', uid);
    final list = (rows as List).cast<Map<String, dynamic>>();
    if (list.isEmpty) {
      await saveRates(RateRow.seed);
      return RateRow.seed;
    }
    // Preserve canonical order based on seed.
    final byType = {
      for (final r in list)
        r['type'] as String: RateRow(
          type: AnimalType.values.firstWhere((t) => t.name == r['type']),
          dayRates: (r['day_rates'] as List)
              .map((e) => (e as num).toInt())
              .toList(),
        ),
    };
    return [
      for (final s in RateRow.seed)
        byType[s.type.name] ?? s,
    ];
  }

  @override
  Future<void> saveRates(List<RateRow> rates) async {
    final uid = _uid();
    await client.from('rates').upsert(
          [
            for (final r in rates)
              {
                'user_id': uid,
                'type': r.type.name,
                'day_rates': r.dayRates,
              }
          ],
          onConflict: 'user_id,type',
        );
  }
}
