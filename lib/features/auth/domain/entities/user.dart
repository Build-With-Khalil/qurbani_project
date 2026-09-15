import 'package:equatable/equatable.dart';

enum UserRole { admin, operator }

class User extends Equatable {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? branch;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.branch,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, phone, role, branch];
}
