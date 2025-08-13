import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/features/patient/profile_settings/state_management/patient_profile_settings_state.dart';

import '../../../shared/features/providers/patient_profile_provider/patient_profile.dart';
import '../../../shared/features/providers/patient_profile_provider/private_patient_profile_service.dart';

part 'patient_profile_settings_provider.g.dart';

@riverpod
class PatientProfileSettingsNotifier extends _$PatientProfileSettingsNotifier {
  @override
  PatientProfileSettingsState build() {
    final service = ref.read(privatePatientProfileServiceProvider);

    Future.microtask(() => service.addProfileListenerCallback(_profileListener, triggerOnCreate: true));
    ref.onDispose(() => service.removeProfileListenerCallback(_profileListener));

    return PatientProfileSettingsState(
      isLoading: true,
      nameController: TextEditingController(),
      contactController: TextEditingController(),
    );
  }

  void _profileListener(PatientProfile? oldProfile, PatientProfile? newProfile) {
    newProfile ??= PatientProfile.empty();

    state.nameController.text = newProfile.name;
    state.contactController.text = newProfile.contact;

    state = state.copyWith(
      isLoading: false,
    );
  }

  Future<void> save() async {
    PatientProfile profile = PatientProfile(
      name: state.nameController.text.trim(),
      contact: state.contactController.text.trim(),
    );

    await ref.read(privatePatientProfileServiceProvider).updateProfile(profile.toMap());
  }
}
