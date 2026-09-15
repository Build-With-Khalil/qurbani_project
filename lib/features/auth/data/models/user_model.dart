import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.role,
    super.branch,
  });

  factory UserModel.fromRow(Map<String, dynamic> m) => UserModel(
        id: m['id'] as String,
        name: m['name'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == (m['role'] as String? ?? 'operator'),
          orElse: () => UserRole.operator,
        ),
        branch: m['branch'] as String?,
      );

  Map<String, dynamic> toRow() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role.name,
        'branch': branch,
      };
}
