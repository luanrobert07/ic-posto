import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:posto/core/utils/utils.dart';
import 'package:posto/features/professional/profile_settings/exceptions_rule_editor/state_management/rule_editor_state.dart';
import 'package:posto/features/shared/features/dialogs/base_dialog.dart';

import '../../base/state_management/work_period.dart';
import '../logic/schedule_exceptions_service.dart';
import '../models/day_selection_mode.dart';
import '../models/exception_rule_model.dart';

part 'rule_editor_provider.g.dart';

@riverpod
class RuleEditorNotifier extends _$RuleEditorNotifier {
  late final ScheduleExceptionsService _scheduleExceptionsService = ref.read(scheduleExceptionsServiceProvider.notifier);
  bool _hasLoadedEditingRule = false;
  ExceptionRuleModel? _oldEditingRule;

  @override
  RuleEditorState build(Key key) {
    final now = Utils.dateNow();
    return RuleEditorState(
      focusedDay: now,
      calendarStartDay: now,
      calendarEndDay: now.copyWith(year: now.year+2),
      rule: ExceptionRuleModel(),
    );
  }

  void selectDay(DateTime day) {
    ExceptionRuleModel rule = state.rule;

    switch(state.daySelectionMode) {
      case DaySelectionMode.singleDay:
        rule = rule.copyWith(selectedDays: [day]);
        break;

      case DaySelectionMode.range:
        if (rule.rangeStartDay == null || rule.rangeEndDay != null) {
          rule = rule.copyWith(rangeStartDay: day, rangeEndDay: null);
          break;
        }

        if (day.isAfter(rule.rangeStartDay!)) {
          rule = rule.copyWith(rangeEndDay: day);
          break;
        }

        rule = rule.copyWith(
          rangeStartDay: day,
          rangeEndDay: rule.rangeStartDay,
        );
        break;

      case DaySelectionMode.multipleDays:
        List<DateTime>? selectedDays = List<DateTime>.from(rule.selectedDays ?? []);
        if (selectedDays.contains(day)) {
          selectedDays.remove(day);
        } else {
          selectedDays.add(day);
        }

        if (selectedDays.isEmpty) selectedDays = null;

        rule = rule.copyWith(
          selectedDays: selectedDays,
        );
        break;
    }

    state = state.copyWith(rule: rule);
  }

  void setFocusedDay(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);
  }

  void setDaySelectionMode(DaySelectionMode? daySelectionMode) {
    if (daySelectionMode == null) return;
    if (daySelectionMode == state.daySelectionMode) return;

    state = state.copyWith(
      daySelectionMode: daySelectionMode,
      rule: state.rule.copyWith(
        selectedDays: [],
        rangeStartDay: null,
        rangeEndDay: null,
      ),
    );
  }

  void setMarkDaysAsUnavailable(bool markDaysAsUnavailable) {
    state = state.copyWith(
      rule: state.rule.copyWith(
        markDaysAsUnavailable: markDaysAsUnavailable,
      ),
    );
  }

  void updatePeriod(int id, WorkPeriod newPeriod) {
    final workPeriods = List<WorkPeriod>.from(state.rule.workPeriods);

    workPeriods[id] = newPeriod;

    state = state.copyWith(
      rule: state.rule.copyWith(
        workPeriods: workPeriods,
      ),
    );
  }

  void removePeriod() {
    final workPeriods = List<WorkPeriod>.from(state.rule.workPeriods);

    if (workPeriods.isEmpty) return;
    workPeriods.removeLast();

    state = state.copyWith(
      rule: state.rule.copyWith(
        workPeriods: workPeriods,
      ),
    );
  }

  void addPeriod() {
    final workPeriods = List<WorkPeriod>.from(state.rule.workPeriods);

    workPeriods.add(WorkPeriod.empty());

    state = state.copyWith(
      rule: state.rule.copyWith(
        workPeriods: workPeriods,
      ),
    );
  }

  void save(bool isEditing) async {
    ExceptionRuleModel rule = state.rule;

    if (!rule.markDaysAsUnavailable && rule.workPeriods.isEmpty) return;
    for (final period in rule.workPeriods) {
      if (!period.isValid()) return;
    }

    if (rule.markDaysAsUnavailable) {
      rule = rule.copyWith(workPeriods: []);
    }

    final newRule = rule.normalize(state.daySelectionMode);

    if (_scheduleExceptionsService.doesRuleConflictWithAppointments(rule)) {
      final confirmed = await BaseDialog.show(
        title: 'Warning',
        body: const Text(
          'The rule you are trying to create conflicts with one or more existing appointments.\n'
              'You can reschedule them later in the Appointment Management screen.\n'
              'Do you want to proceed?',
          textAlign: TextAlign.center,
        ),
        cancelCallback: (context) {
          context.pop(false);
        },
        confirmCallback: (context) {
          context.pop(true);
        },
      );

      if (!confirmed) return;
    }

    if (isEditing) {
      await _scheduleExceptionsService.substituteRule(_oldEditingRule!, newRule);
    } else {
      await _scheduleExceptionsService.saveNewRule(newRule);
    }
  }

  void loadRule(ExceptionRuleModel? rule) {
    if (rule == null) return;
    if (_hasLoadedEditingRule) return;

    _hasLoadedEditingRule = true;
    _oldEditingRule = rule.copyWith();
    state = state.copyWith(
      rule: rule,
      daySelectionMode: rule.selectedDays == null ? DaySelectionMode.range : (rule.selectedDays!.length == 1 ? DaySelectionMode.singleDay : DaySelectionMode.multipleDays),
    );
  }
}
