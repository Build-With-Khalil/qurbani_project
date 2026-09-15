import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/org_settings.dart';
import '../../domain/usecases/get_org_settings.dart';
import '../../domain/usecases/save_org_settings.dart';

part 'org_settings_event.dart';
part 'org_settings_state.dart';

class OrgSettingsBloc extends Bloc<OrgSettingsEvent, OrgSettingsState> {
  final GetOrgSettings getOrg;
  final SaveOrgSettings saveOrg;

  OrgSettingsBloc({required this.getOrg, required this.saveOrg})
      : super(const OrgSettingsState()) {
    on<OrgSettingsLoadRequested>(_onLoad);
    on<OrgSettingsFieldChanged>(_onChange);
    on<OrgSettingsWatermarkToggled>(_onToggleWatermark);
    on<OrgSettingsSaveRequested>(_onSave);
  }

  Future<void> _onLoad(
      OrgSettingsLoadRequested e, Emitter<OrgSettingsState> emit) async {
    emit(state.copyWith(status: OrgSettingsStatus.loading));
    final r = await getOrg(const NoParams());
    r.fold(
      (f) => emit(state.copyWith(
          status: OrgSettingsStatus.failure, errorMessage: f.message)),
      (org) =>
          emit(state.copyWith(status: OrgSettingsStatus.ready, settings: org)),
    );
  }

  void _onChange(
      OrgSettingsFieldChanged e, Emitter<OrgSettingsState> emit) {
    if (state.settings == null) return;
    emit(state.copyWith(
      settings: state.settings!.copyWith(
        name: e.name,
        address: e.address,
        contact: e.contact,
        ntn: e.ntn,
        footerUrdu: e.footerUrdu,
        footerEnglish: e.footerEnglish,
      ),
      dirty: true,
    ));
  }

  void _onToggleWatermark(
      OrgSettingsWatermarkToggled e, Emitter<OrgSettingsState> emit) {
    if (state.settings == null) return;
    emit(state.copyWith(
      settings: state.settings!.copyWith(watermarkOnPdf: e.value),
      dirty: true,
    ));
  }

  Future<void> _onSave(
      OrgSettingsSaveRequested e, Emitter<OrgSettingsState> emit) async {
    if (state.settings == null) return;
    emit(state.copyWith(status: OrgSettingsStatus.saving));
    final r = await saveOrg(state.settings!);
    r.fold(
      (f) => emit(state.copyWith(
          status: OrgSettingsStatus.failure, errorMessage: f.message)),
      (_) => emit(state.copyWith(status: OrgSettingsStatus.saved, dirty: false)),
    );
  }
}
