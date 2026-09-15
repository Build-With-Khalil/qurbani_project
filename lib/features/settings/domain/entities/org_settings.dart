import 'package:equatable/equatable.dart';

class OrgSettings extends Equatable {
  final String name;
  final String address;
  final String contact;
  final String? ntn;
  final String footerUrdu;
  final String footerEnglish;
  final bool watermarkOnPdf;

  const OrgSettings({
    required this.name,
    required this.address,
    required this.contact,
    this.ntn,
    required this.footerUrdu,
    required this.footerEnglish,
    required this.watermarkOnPdf,
  });

  static const OrgSettings seed = OrgSettings(
    name: 'Alkhidmat Ijtemai Qurbani',
    address: 'Block 5, Gulshan-e-Iqbal · Karachi',
    contact: '0311 555 8000',
    ntn: '0091234-5',
    footerUrdu: 'بسم اللہ، اللہ اکبر — Qubool ho qurbani',
    footerEnglish: 'JazakAllah Khair for your trust.',
    watermarkOnPdf: true,
  );

  OrgSettings copyWith({
    String? name,
    String? address,
    String? contact,
    String? ntn,
    String? footerUrdu,
    String? footerEnglish,
    bool? watermarkOnPdf,
  }) =>
      OrgSettings(
        name: name ?? this.name,
        address: address ?? this.address,
        contact: contact ?? this.contact,
        ntn: ntn ?? this.ntn,
        footerUrdu: footerUrdu ?? this.footerUrdu,
        footerEnglish: footerEnglish ?? this.footerEnglish,
        watermarkOnPdf: watermarkOnPdf ?? this.watermarkOnPdf,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'contact': contact,
        'ntn': ntn,
        'footerUrdu': footerUrdu,
        'footerEnglish': footerEnglish,
        'watermarkOnPdf': watermarkOnPdf,
      };

  factory OrgSettings.fromMap(Map<dynamic, dynamic> m) => OrgSettings(
        name: m['name'] as String,
        address: m['address'] as String,
        contact: m['contact'] as String,
        ntn: m['ntn'] as String?,
        footerUrdu: m['footerUrdu'] as String,
        footerEnglish: m['footerEnglish'] as String,
        watermarkOnPdf: m['watermarkOnPdf'] as bool,
      );

  @override
  List<Object?> get props =>
      [name, address, contact, ntn, footerUrdu, footerEnglish, watermarkOnPdf];
}
