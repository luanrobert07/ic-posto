import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posto/features/professional/profile_settings/base/state_management/work_period.dart';

part 'professional_profile_settings_state.freezed.dart';

@freezed
abstract class ProfessionalProfileSettingsState with _$ProfessionalProfileSettingsState {
  const factory ProfessionalProfileSettingsState({
    required bool isLoading,
    required TextEditingController nameController,
    required TextEditingController contactController,
    required TextEditingController sessionDurationController,
    required List<List<WorkPeriod>> schedule,
  }) = _ProfessionalProfileSettingsState;
}
