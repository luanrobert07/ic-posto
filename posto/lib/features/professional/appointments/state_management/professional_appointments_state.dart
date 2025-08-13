import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/features/appointment/models/appointment.dart';

part 'professional_appointments_state.freezed.dart';

@freezed
abstract class ProfessionalAppointmentsState with _$ProfessionalAppointmentsState {
  const factory ProfessionalAppointmentsState({
    @Default(false) bool isLoading,
    @Default([]) List<Appointment> pendingAppointments,
    @Default([]) List<Appointment> bookedAppointments,
  }) = _ProfessionalAppointmentsState;
}
