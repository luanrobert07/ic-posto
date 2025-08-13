import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import 'package:posto/features/professional/home/state_management/professional_home_state.dart';
import 'package:posto/features/shared/features/providers/patient_profile_provider/public_patient_profile_service.dart';
import 'package:posto/features/shared/features/providers/professional_profile_provider/private_professional_profile_service.dart';
import 'package:posto/features/shared/features/providers/professional_profile_provider/professional_profile.dart';

part 'professional_home_provider.g.dart';

@riverpod
class ProfessionalHomeNotifier extends _$ProfessionalHomeNotifier {
  late final _profileCacheService = ref.read(profileCacheServiceProvider.notifier);

  @override
  ProfessionalHomeState build() {
    ref.read(privateProfessionalProfileServiceProvider).addProfileListenerCallback(_onProfileUpdate);
    ref.onDispose(() => ref.read(privateProfessionalProfileServiceProvider).removeProfileListenerCallback(_onProfileUpdate));

    return ProfessionalHomeState();
  }

  void _onProfileUpdate(ProfessionalProfile? oldProfile, ProfessionalProfile? newProfile) async {
    Set<String> profileIds = {};

    for (final appointment in newProfile!.bookedAppointments) {
      profileIds.add(appointment.patientId!);
    }
    for (final appointment in newProfile.pendingAppointments) {
      profileIds.add(appointment.patientId!);
    }

    final newOnes = _profileCacheService.filterIdsForNewOnes(profileIds.toList());
    final profiles = await ref.read(publicPatientProfileServiceProvider).getMultipleProfilesFromIds(newOnes);
    _profileCacheService.addProfiles(profiles);

    state = state.copyWith(
      profile: newProfile,
    );
  }
}
