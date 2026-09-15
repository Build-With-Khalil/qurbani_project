import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String? address;
  final String? cnic;
  final String? note;

  const Customer({
    required this.id,
    required this.name,
    required this.mobile,
    this.address,
    this.cnic,
    this.note,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'address': address,
        'cnic': cnic,
        'note': note,
      };

  factory Customer.fromMap(Map<dynamic, dynamic> m) => Customer(
        id: m['id'] as String,
        name: m['name'] as String,
        mobile: m['mobile'] as String,
        address: m['address'] as String?,
        cnic: m['cnic'] as String?,
        note: m['note'] as String?,
      );

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, mobile, address, cnic, note];
}
