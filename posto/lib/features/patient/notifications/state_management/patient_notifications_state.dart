import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_notifications_state.freezed.dart';

@freezed
abstract class PatientNotificationsState with _$PatientNotificationsState {
  const factory PatientNotificationsState({
    @Default(true) bool appointmentReminders,
    @Default(true) bool examResults,
    @Default(false) bool promotionalMessages,
    @Default(true) bool systemUpdates,
    @Default(false) bool isLoading,
  }) = _PatientNotificationsState;
}
