import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/features/providers/patient_profile_provider/patient_profile.dart';

part 'patient_profile_settings_state.freezed.dart';

@freezed
abstract class PatientProfileSettingsState with _$PatientProfileSettingsState {
  const factory PatientProfileSettingsState({
    required bool isLoading,
    required TextEditingController nameController,
    required TextEditingController contactController,
  }) = _PatientProfileSettingsState;
}
