import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/features/providers/patient_profile_provider/patient_profile.dart';

part 'patient_appointments_state.freezed.dart';

@freezed
abstract class PatientAppointmentsState with _$PatientAppointmentsState {
  const factory PatientAppointmentsState({
    PatientProfile? profile,
    @Default(false) bool isLoadingProfiles,
  }) = _PatientAppointmentsState;
}
