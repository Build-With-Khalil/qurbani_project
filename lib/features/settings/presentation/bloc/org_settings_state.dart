part of 'org_settings_bloc.dart';

enum OrgSettingsStatus { initial, loading, ready, saving, saved, failure }

class OrgSettingsState extends Equatable {
  final OrgSettingsStatus status;
  final OrgSettings? settings;
  final bool dirty;
  final String? errorMessage;

  const OrgSettingsState({
    this.status = OrgSettingsStatus.initial,
    this.settings,
    this.dirty = false,
    this.errorMessage,
  });

  OrgSettingsState copyWith({
    OrgSettingsStatus? status,
    OrgSettings? settings,
    bool? dirty,
    String? errorMessage,
  }) =>
      OrgSettingsState(
        status: status ?? this.status,
        settings: settings ?? this.settings,
        dirty: dirty ?? this.dirty,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, settings, dirty, errorMessage];
}
