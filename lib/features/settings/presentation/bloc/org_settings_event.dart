part of 'org_settings_bloc.dart';

abstract class OrgSettingsEvent extends Equatable {
  const OrgSettingsEvent();
  @override
  List<Object?> get props => [];
}

class OrgSettingsLoadRequested extends OrgSettingsEvent {
  const OrgSettingsLoadRequested();
}

class OrgSettingsFieldChanged extends OrgSettingsEvent {
  final String? name;
  final String? address;
  final String? contact;
  final String? ntn;
  final String? footerUrdu;
  final String? footerEnglish;
  const OrgSettingsFieldChanged({
    this.name,
    this.address,
    this.contact,
    this.ntn,
    this.footerUrdu,
    this.footerEnglish,
  });

  @override
  List<Object?> get props =>
      [name, address, contact, ntn, footerUrdu, footerEnglish];
}

class OrgSettingsWatermarkToggled extends OrgSettingsEvent {
  final bool value;
  const OrgSettingsWatermarkToggled(this.value);
  @override
  List<Object?> get props => [value];
}

class OrgSettingsSaveRequested extends OrgSettingsEvent {
  const OrgSettingsSaveRequested();
}
