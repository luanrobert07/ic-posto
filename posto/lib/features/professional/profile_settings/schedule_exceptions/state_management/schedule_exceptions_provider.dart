import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/features/professional/profile_settings/schedule_exceptions/state_management/schedule_exceptions_state.dart';

import '../../../../shared/features/providers/professional_profile_provider/private_professional_profile_service.dart';
import '../../../../shared/features/providers/professional_profile_provider/professional_profile.dart';

part 'schedule_exceptions_provider.g.dart';

// ToDo add way to re-schedule appointments
// ToDo organize UI and provider code
@riverpod
class ScheduleExceptionNotifier extends _$ScheduleExceptionNotifier {
  late final PrivateProfessionalProfileService _profileProvider = ref.read(privateProfessionalProfileServiceProvider);
  ProfessionalProfile? _profile;

  @override
  ScheduleExceptionsState build() {
    Future.microtask(() {
      _profileProvider.addProfileListenerCallback(_onProfileUpdate, triggerOnCreate: true);
    });
    ref.onDispose(() => _profileProvider.removeProfileListenerCallback(_onProfileUpdate));

    return ScheduleExceptionsState(
      isLoading: false,
    );
  }

  void _onProfileUpdate(ProfessionalProfile? oldProfile, ProfessionalProfile? newProfile) {
    _profile = newProfile;
    state = state.copyWith(existingRulesExceptions: _profile!.scheduleRulesExceptions);
  }
}
