import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:posto/features/professional/profile_settings/exceptions_rule_editor/models/exception_rule_model.dart';

part 'schedule_exceptions_state.freezed.dart';

@freezed
abstract class ScheduleExceptionsState with _$ScheduleExceptionsState {
  const factory ScheduleExceptionsState({
    required bool isLoading,
    @Default([]) List<ExceptionRuleModel> existingRulesExceptions,
  }) = _ScheduleExceptionsState;
}
