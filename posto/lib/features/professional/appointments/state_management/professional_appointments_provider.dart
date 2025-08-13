import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import 'package:posto/features/professional/appointments/state_management/professional_appointments_state.dart';
import 'package:posto/features/shared/features/appointment/models/appointment.dart';

import '../../../shared/features/providers/patient_profile_provider/patient_profile.dart';
import '../../../shared/features/providers/patient_profile_provider/public_patient_profile_service.dart';
import '../../../shared/features/providers/professional_profile_provider/private_professional_profile_service.dart';
import '../../../shared/features/providers/professional_profile_provider/professional_profile.dart';
import '../../profile_settings/exceptions_rule_editor/models/exception_rule_model.dart';

part 'professional_appointments_provider.g.dart';

@riverpod
class ProfessionalAppointmentsNotifier extends _$ProfessionalAppointmentsNotifier {
  late final _profileCacheService = ref.read(profileCacheServiceProvider.notifier);
  late final _patientProfileService = ref.read(publicPatientProfileServiceProvider);
  late final _professionalProfileService = ref.read(privateProfessionalProfileServiceProvider);

  @override
  ProfessionalAppointmentsState build() {
    Future.microtask(() {
      _professionalProfileService.addProfileListenerCallback(_professionalProfileListener, triggerOnCreate: true);
    });
    ref.onDispose(() => _professionalProfileService.removeProfileListenerCallback(_professionalProfileListener));

    return ProfessionalAppointmentsState(
      isLoading: true,
    );
  }

  void _professionalProfileListener(ProfessionalProfile? oldProfile,ProfessionalProfile? updatedProfile) async {
    if (updatedProfile == null) return;

    print('received professional profile update');
    _loadNewPatientProfiles(updatedProfile);
    _loadAppointments(updatedProfile);
  }

  Future<void> _loadNewPatientProfiles(ProfessionalProfile profile) async {
    final patientIds = [
      ...profile.pendingAppointments,
      ...profile.bookedAppointments,
    ].map((a) => a.patientId!)
        .toSet()
        .toList();

    final newIds = _profileCacheService.filterIdsForNewOnes(patientIds);
    final newProfiles = await _patientProfileService.getMultipleProfilesFromIds(newIds);
    _profileCacheService.addProfiles(newProfiles);

    state = state.copyWith(
      isLoading: false,
    );
  }

  void _loadAppointments(ProfessionalProfile profile) {
    final List<Appointment> pending = List<Appointment>.from(profile.pendingAppointments);
    final List<Appointment> booked = List<Appointment>.from(profile.bookedAppointments);
    final List<Appointment> allAppointments = [...pending, ...booked];

    for (final appointment in allAppointments) {
      if (_isConflict(appointment, profile.scheduleRulesExceptions)) {
        appointment.hasConflict = true;
      }
    }

    state = state.copyWith(
      pendingAppointments: pending,
      bookedAppointments: booked,
    );
  }

  bool _isConflict(Appointment appointment, List<ExceptionRuleModel> rules) {
    return rules.any((rule) => rule.doesRuleAffectAppointment(appointment));
  }

  Future<void> declinePendingAppointment(Appointment appointment) async {
    state = state.copyWith(isLoading: true);
    return _professionalProfileService.declinePendingAppointment(appointment);
  }

  Future<void> acceptPendingAppointment(Appointment appointment) async {
    state = state.copyWith(isLoading: true);
    return _professionalProfileService.acceptPendingAppointment(appointment);
  }

  PatientProfile getPatientProfileFromId(String id) {
    final profileCache = ref.read(profileCacheServiceProvider);
    return profileCache[id];
  }
}
