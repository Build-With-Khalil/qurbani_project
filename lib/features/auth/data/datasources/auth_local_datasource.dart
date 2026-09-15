import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../settings/domain/entities/org_settings.dart';
import '../../../settings/domain/entities/rate.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> signIn({
    required String phone,
    required String pin,
    required UserRole role,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SupabaseClient client;

  AuthLocalDataSourceImpl({required this.client});

  String _digits(String phone) => phone.replaceAll(RegExp(r'\D'), '');

  String _email(String phone, UserRole role) {
    final digits = _digits(phone);
    if (digits.isEmpty) {
      throw ValidationException('Valid phone number required.');
    }
    return '${role.name}_$digits@qurbani.app';
  }

  String _password(String pin) => 'qz$pin';

  @override
  Future<UserModel> signIn({
    required String phone,
    required String pin,
    required UserRole role,
  }) async {
    if (phone.trim().isEmpty || pin.trim().isEmpty) {
      throw ValidationException('Phone aur PIN dono required hain.');
    }
    final email = _email(phone, role);
    final password = _password(pin);

    AuthResponse? response;
    try {
      response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (_isInvalidCreds(e)) {
        response = await _signUpAndSeed(
          email: email,
          password: password,
          phone: phone,
          role: role,
        );
      } else {
        throw UnauthorizedException(e.message);
      }
    }

    final session = response.session;
    final authUser = response.user;
    if (session == null || authUser == null) {
      throw UnauthorizedException('Sign in failed.');
    }

    final profile = await _ensureProfile(
      authUser.id,
      phone: phone,
      role: role,
    );
    return profile;
  }

  bool _isInvalidCreds(AuthException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('invalid login') ||
        msg.contains('invalid credentials') ||
        msg.contains('user not found') ||
        e.statusCode == '400';
  }

  Future<AuthResponse> _signUpAndSeed({
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    final res = await client.auth.signUp(email: email, password: password);
    if (res.user == null) {
      throw UnauthorizedException('Sign up failed.');
    }
    // If email confirmations are enabled there will be no session — try sign-in.
    if (res.session == null) {
      return client.auth
          .signInWithPassword(email: email, password: password);
    }
    return res;
  }

  Future<UserModel> _ensureProfile(
    String userId, {
    required String phone,
    required UserRole role,
  }) async {
    final existing = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (existing != null) {
      return UserModel.fromRow(existing);
    }

    final defaultName =
        role == UserRole.admin ? 'Muhammad Khalil' : 'Ahmed Raza';
    final row = {
      'id': userId,
      'name': defaultName,
      'phone': phone,
      'role': role.name,
      'branch': 'Karachi branch',
    };
    final inserted =
        await client.from('profiles').insert(row).select().single();

    await _seedDefaults(userId);

    return UserModel.fromRow(inserted);
  }

  Future<void> _seedDefaults(String userId) async {
    final orgExists = await client
        .from('org_settings')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();
    if (orgExists == null) {
      const seed = OrgSettings.seed;
      await client.from('org_settings').insert({
        'user_id': userId,
        'name': seed.name,
        'address': seed.address,
        'contact': seed.contact,
        'ntn': seed.ntn,
        'footer_urdu': seed.footerUrdu,
        'footer_english': seed.footerEnglish,
        'watermark_on_pdf': seed.watermarkOnPdf,
      });
    }

    final existingRates = await client
        .from('rates')
        .select('type')
        .eq('user_id', userId);
    if ((existingRates as List).isEmpty) {
      await client.from('rates').insert([
        for (final r in RateRow.seed)
          {
            'user_id': userId,
            'type': r.type.name,
            'day_rates': r.dayRates,
          }
      ]);
    }
  }

  @override
  Future<void> signOut() => client.auth.signOut();

  @override
  Future<UserModel?> getCurrentUser() async {
    final session = client.auth.currentSession;
    final authUser = client.auth.currentUser;
    if (session == null || authUser == null) return null;

    final row = await client
        .from('profiles')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();
    if (row == null) return null;
    return UserModel.fromRow(row);
  }
}
