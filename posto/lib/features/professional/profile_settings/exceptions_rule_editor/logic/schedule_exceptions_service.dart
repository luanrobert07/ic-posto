import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/features/shared/features/providers/professional_profile_provider/private_professional_profile_service.dart';

import '../models/exception_rule_model.dart';

part 'schedule_exceptions_service.g.dart';

@riverpod
class ScheduleExceptionsService extends _$ScheduleExceptionsService {
  @override
  void build() {
  }

  Future<void> saveNewRule(ExceptionRuleModel newRule) async {
    final profileService = ref.read(privateProfessionalProfileServiceProvider);
    return profileService.addScheduleRulesExceptions(newRule);
  }

  Future<void> substituteRule(ExceptionRuleModel oldRule, ExceptionRuleModel newRule) async {
    final profileService = ref.read(privateProfessionalProfileServiceProvider);
    return profileService.substituteScheduleRulesExceptions(oldRule, newRule);
  }

  bool doesRuleConflictWithAppointments(ExceptionRuleModel rule) {
    final profileService = ref.read(privateProfessionalProfileServiceProvider);
    final profile = profileService.getProfile();
    final appointments = [...profile!.pendingAppointments, ...profile.bookedAppointments];

    for (final appointment in appointments) {
      if (!rule.doesRuleAffectAppointment(appointment)) continue;

      return true;
    }

    return false;
  }
}
