import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInit {
  SupabaseInit._();

  static const _url = 'https://wpdfcisiceunqfgultqy.supabase.co';
  static const _anonKey = 'sb_publishable_uSMYBB2h0SxP8ld6BivtWg_wXPouS85';

  static Future<void> init() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
