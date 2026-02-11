import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'patient_notifications_state.dart';

part 'patient_notifications_provider.g.dart';

@riverpod
class PatientNotificationsProvider
    extends _$PatientNotificationsProvider {
  @override
  PatientNotificationsState build() {
    return const PatientNotificationsState();
  }

  void toggleAppointmentReminders(bool value) {
    state = state.copyWith(appointmentReminders: value);
  }

  void toggleExamResults(bool value) {
    state = state.copyWith(examResults: value);
  }

  void togglePromotionalMessages(bool value) {
    state = state.copyWith(promotionalMessages: value);
  }

  void toggleSystemUpdates(bool value) {
    state = state.copyWith(systemUpdates: value);
  }

  Future<void> savePreferences() async {
    state = state.copyWith(isLoading: true);

    // 🔌 Backend aqui (Supabase / API / Firebase)
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(isLoading: false);
  }
}
