import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:posto/core/utils/utils.dart';
import 'package:posto/features/shared/extensions/time_of_day_extension.dart';
import 'package:posto/features/shared/features/appointment/models/appointment.dart';

import '../../base/state_management/work_period.dart';
import 'day_selection_mode.dart';

part 'exception_rule_model.freezed.dart';

@freezed
abstract class ExceptionRuleModel with _$ExceptionRuleModel {
  const factory ExceptionRuleModel({
    DateTime? rangeStartDay,
    DateTime? rangeEndDay,
    List<DateTime>? selectedDays,
    @Default([]) List<WorkPeriod> workPeriods,

    @Default(true) bool markDaysAsUnavailable,
  }) = _ExceptionRuleModel;
}

extension ExceptionRuleModelHelper on ExceptionRuleModel {
  ExceptionRuleModel normalize(DaySelectionMode selectionMode) {
    switch(selectionMode) {
      case DaySelectionMode.singleDay:
      case DaySelectionMode.multipleDays:
        return ExceptionRuleModel(
          selectedDays: selectedDays,
          workPeriods: workPeriods,
          markDaysAsUnavailable: markDaysAsUnavailable,
        );

      case DaySelectionMode.range:
        return ExceptionRuleModel(
          rangeStartDay: rangeStartDay,
          rangeEndDay: rangeEndDay,
          workPeriods: workPeriods,
          markDaysAsUnavailable: markDaysAsUnavailable,
        );
    }
  }

  ExceptionRuleModel fromJson(Map<String, dynamic> json) {
    final List<Timestamp>? days = (json['days'] as List?)?.map((item) => Utils.parseTimestamp(item)).cast<Timestamp>().toList();
    final Map<String, dynamic>? range = (json['range'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, Utils.parseTimestamp(v)));
    final List<String> periods = List<String>.from(json['periods'] ?? []);

    return ExceptionRuleModel(
      rangeStartDay: range?['start']?.toDate().toUtc(),
      rangeEndDay: range?['end']?.toDate().toUtc(),
      selectedDays: days?.map((timestamp) => timestamp.toDate().toUtc()).toList(),
      workPeriods: periods.map((period) => WorkPeriod.fromString(period)).toList(),
      markDaysAsUnavailable: periods.isEmpty,
    );
  }

  Map<String, dynamic> toMap([DaySelectionMode? selectionMode]) {
    selectionMode ??= rangeStartDay != null ? DaySelectionMode.range : DaySelectionMode.multipleDays;

    switch(selectionMode) {
      case DaySelectionMode.singleDay:
      case DaySelectionMode.multipleDays:
        return _mapSelectedDaysRule(selectedDays, workPeriods);

      case DaySelectionMode.range:
        return _mapRangeRule(rangeStartDay, rangeEndDay, workPeriods);
    }
  }

  Map<String, dynamic> _mapSelectedDaysRule(List<DateTime>? selectedDays, List<WorkPeriod> workPeriods) {
    if (selectedDays == null || selectedDays.isEmpty) throw Exception('Cant save rule without any days selected');

    return {
      'days': (selectedDays.toList()..sort()).map((day) => Timestamp.fromDate(day).seconds).toList(),
      'periods': workPeriods.map((workPeriod) => workPeriod.encodeToServer()).toList(),
    };
  }

  Map<String, dynamic> _mapRangeRule(DateTime? rangeStart, DateTime? rangeEnd, List<WorkPeriod> workPeriods) {
    if (rangeStart == null || rangeEnd == null) throw Exception('Cant save rule without selecting proper range');

    return {
      'range': {
        'start': Timestamp.fromDate(rangeStart).seconds,
        'end': Timestamp.fromDate(rangeEnd).seconds,
      },
      'periods': workPeriods.map((workPeriod) => workPeriod.encodeToServer()).toList(),
    };
  }

  /// Return if last affected day by rule is before today (expired)
  /// If rule is broken (malformed), it will return true
  bool hasRuleExpired(DateTime today) {
    if (rangeStartDay != null && rangeEndDay != null) return rangeEndDay!.isBefore(today);

    // Malformed rules count as expired
    if (rangeStartDay != null || rangeEndDay != null) return true;
    if (selectedDays == null || selectedDays!.isEmpty) return true;

    return selectedDays!.last.isBefore(today);
  }

  bool isRuleSameDayAsDate(DateTime date) {
    if (rangeStartDay != null && rangeEndDay != null) {
      return rangeStartDay!.isBefore(date) && date.isBefore(rangeEndDay!);
    }

    if (rangeStartDay != null || rangeEndDay != null) return false;
    if (selectedDays == null || selectedDays!.isEmpty) return false;

    final isContained = selectedDays!.any((day) => isSameDay(date, day));

    return isContained;
  }

  bool doesRuleAffectAppointment(Appointment appointment) {
    final start = appointment.start.toDate();
    final end = appointment.end.toDate();
    final isContained = isRuleSameDayAsDate(start);

    if (!isContained) return false;
    if (markDaysAsUnavailable) return true;

    final startTime = TimeOfDay(hour: start.hour, minute: start.minute);
    final endTime = TimeOfDay(hour: end.hour, minute: end.minute);
    final isAllowed = workPeriods.any((period) => period.begin.isBeforeOrEqual(startTime) && endTime.isBeforeOrEqual(period.end));

    return !isAllowed;
  }
}
