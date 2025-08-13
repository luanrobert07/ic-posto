import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/day_selection_mode.dart';
import '../models/exception_rule_model.dart';

part 'rule_editor_state.freezed.dart';

@freezed
abstract class RuleEditorState with _$RuleEditorState {
  const factory RuleEditorState({
    required DateTime focusedDay,
    required DateTime calendarStartDay,
    required DateTime calendarEndDay,
    @Default(DaySelectionMode.singleDay) DaySelectionMode daySelectionMode,

    @Default(false) bool isEditingRule,
    required ExceptionRuleModel rule,
  }) = _RuleEditorState;
}
