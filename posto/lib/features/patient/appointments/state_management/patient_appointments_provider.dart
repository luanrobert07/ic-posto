import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/features/patient/appointments/state_management/patient_appointments_state.dart';
import 'package:posto/features/shared/features/providers/patient_profile_provider/patient_profile.dart';
import 'package:posto/features/shared/features/providers/professional_profile_provider/professional_profile.dart';

import '../../../../core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import '../../../shared/features/providers/patient_profile_provider/private_patient_profile_service.dart';
import '../../../shared/features/providers/professional_profile_provider/public_professional_profile_service.dart';

part 'patient_appointments_provider.g.dart';

@riverpod
class PatientAppointmentsNotifier extends _$PatientAppointmentsNotifier {
  late final _profileCacheService = ref.read(profileCacheServiceProvider.notifier);
  late final _patientProfileService = ref.read(privatePatientProfileServiceProvider);
  late final _professionalProfileService = ref.read(publicProfessionalProfileServiceProvider);

  @override
  PatientAppointmentsState build() {
    _patientProfileService.addProfileListenerCallback(_patientProfileListener);
    ref.onDispose(() => _patientProfileService.removeProfileListenerCallback(_patientProfileListener));

    final profile = ref.read(privatePatientProfileServiceProvider).getProfile();
    Future.microtask(() => _loadNewProfessionalProfiles(profile));

    return PatientAppointmentsState(
      profile: profile,
      isLoadingProfiles: true,
    );
  }

  void _patientProfileListener(PatientProfile? oldProfile,PatientProfile? updatedProfile) async {
    print('received patient profile update');
    await _loadNewProfessionalProfiles(updatedProfile);
  }

  Future<void> _loadNewProfessionalProfiles(PatientProfile? profile) async {
    if (profile == null) throw Exception('Tried to use profile without loading it first');

    final professionalIds = profile.bookedAppointments.map((a) => a.professionalId!).toSet().toList();

    final newIds = _profileCacheService.filterIdsForNewOnes(professionalIds);
    final newProfiles = await _professionalProfileService.getMultipleProfilesFromIds(newIds);
    _profileCacheService.addProfiles(newProfiles);

    state = state.copyWith(
      profile: profile,
      isLoadingProfiles: false,
    );
  }

  ProfessionalProfile getProfessionalProfileFromId(String id) {
    final profileCache = ref.read(profileCacheServiceProvider);
    return profileCache[id];
  }
}
