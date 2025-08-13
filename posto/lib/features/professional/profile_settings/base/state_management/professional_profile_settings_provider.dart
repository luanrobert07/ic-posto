import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/utils/utils.dart';
import 'package:posto/features/professional/profile_settings/base/state_management/professional_profile_settings_state.dart';
import 'package:posto/features/professional/profile_settings/base/state_management/work_period.dart';

import '../../../../shared/features/appointment/logic/appointment_service.dart';
import '../../../../shared/features/providers/professional_profile_provider/private_professional_profile_service.dart';
import '../../../../shared/features/providers/professional_profile_provider/professional_profile.dart';

part 'professional_profile_settings_provider.g.dart';

@riverpod
class ProfessionalProfileSettingsNotifier extends _$ProfessionalProfileSettingsNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  @override
  ProfessionalProfileSettingsState build() {
    final service = ref.read(privateProfessionalProfileServiceProvider);

    Future.microtask(() => service.addProfileListenerCallback(_profileListener, triggerOnCreate: true));
    ref.onDispose(() => service.removeProfileListenerCallback(_profileListener));

    return ProfessionalProfileSettingsState(
      isLoading: true,
      nameController: TextEditingController(),
      contactController: TextEditingController(),
      sessionDurationController: TextEditingController(),
      schedule: [],
    );
  }

  void _profileListener(ProfessionalProfile? oldProfile, ProfessionalProfile? newProfile) {
    newProfile ??= ProfessionalProfile.empty();

    state.nameController.text = newProfile.name;
    state.contactController.text = newProfile.contact;
    state.sessionDurationController.text = newProfile.sessionDuration.toString();

    state = state.copyWith(
      isLoading: false,
      schedule: _appointmentService.parseSchedule(newProfile.scheduleRules),
    );
  }

  Future<void> save() async {
    // ToDo add loading
    ProfessionalProfile profile = ProfessionalProfile(
      name: state.nameController.text.trim(),
      contact: state.contactController.text.trim(),
      scheduleRules: _appointmentService.encodeSchedule(state.schedule),
      sessionDuration: int.parse(state.sessionDurationController.text.trim()),
      timezoneOffset: Utils.getTimezoneOffset(),
    );

    await ref.read(privateProfessionalProfileServiceProvider).updateProfile(profile.toMap());
  }

  void updatePeriod(int day, int id, WorkPeriod newPeriod) {
    final newState = state.copyWith();

    newState.schedule[day][id] = newPeriod;

    state = newState;
  }

  void removePeriod(int day) {
    final newState = state.copyWith();

    if (newState.schedule[day].isEmpty) return;
    newState.schedule[day].removeLast();

    state = newState;
  }

  void addPeriod(int day) {
    final newState = state.copyWith();

    newState.schedule[day].add(WorkPeriod.empty());

    state = newState;
  }
}
