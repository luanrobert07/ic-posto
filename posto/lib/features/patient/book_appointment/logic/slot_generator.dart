import 'package:posto/features/shared/features/providers/professional_profile_provider/professional_profile.dart';

import '../../../../core/utils/utils.dart';
import '../../../professional/profile_settings/base/state_management/work_period.dart';
import '../../../professional/profile_settings/exceptions_rule_editor/models/exception_rule_model.dart';
import '../../../shared/features/appointment/logic/appointment_service.dart';
import '../../../shared/features/appointment/models/appointment.dart';

class SlotGenerator {
  final List<Appointment> pending;
  final List<Appointment> booked;
  final List<List<WorkPeriod>> weeklySchedule;
  final List<ExceptionRuleModel> exceptionRules;
  final int sessionDuration;
  final int timezoneOffset;

  final Map<DateTime, List<DateTime>> _slotsCache = {};

  SlotGenerator({
    required this.pending,
    required this.booked,
    required this.weeklySchedule,
    required this.exceptionRules,
    required this.sessionDuration,
    required this.timezoneOffset,
  });

  factory SlotGenerator.fromProfile(ProfessionalProfile profile) {
    return SlotGenerator(
      pending: profile.pendingAppointments,
      booked: profile.bookedAppointments,
      weeklySchedule: AppointmentService().parseSchedule(profile.scheduleRules),
      exceptionRules: profile.scheduleRulesExceptions,
      sessionDuration: profile.sessionDuration,
      timezoneOffset: profile.timezoneOffset,
    );
  }

  List<DateTime> getSlotsForDay(DateTime? selectedDay) {
    if (selectedDay == null) return [];

    final normalizedDay = _removeTimeFromDateTime(selectedDay);
    if (_slotsCache.containsKey(normalizedDay)) {
      return _slotsCache[normalizedDay]!;
    }

    final slots = _generateSlots(normalizedDay);
    _slotsCache[normalizedDay] = slots;

    return slots;
  }

  List<DateTime> _generateSlots(DateTime selectedDay) {
    final dayIndex = _weekdayFromDay(selectedDay);
    List<WorkPeriod> workPeriods = weeklySchedule[dayIndex];
    final now = DateTime.now();
    final usedSlots = _getUsedSlotsOnDay(selectedDay);
    final allSlots = <DateTime>[];
    final int shiftOffset = Utils.getTimezoneOffset() - timezoneOffset;

    if (sessionDuration == 0) return [];

    final List<WorkPeriod> newWorkPeriods = [];
    for (final rule in exceptionRules) {
      if (rule.isRuleSameDayAsDate(selectedDay)) {
        newWorkPeriods.addAll(rule.workPeriods);
      }
    }
    if (newWorkPeriods.isNotEmpty) {
      workPeriods = _findIntersectingPeriods(newWorkPeriods);
    }

    for (var period in workPeriods) {
      final startMins = period.begin.hour * 60 + period.begin.minute + shiftOffset;
      final endMins = period.end.hour * 60 + period.end.minute + shiftOffset;

      for (int t = startMins; t + sessionDuration <= endMins; t += sessionDuration) {
        final slot = selectedDay.add(Duration(minutes: t));
        
        if (slot.isBefore(now)) continue;
        if (_isSlotUsed(slot, usedSlots)) continue;

        allSlots.add(slot);
      }
    }

    return allSlots;
  }

  bool _isSlotUsed(DateTime slot, List<DateTime> usedSlots) {
    final iso = slot.toUtc().toIso8601String();
    return usedSlots.any((s) => s.toIso8601String() == iso);
  }

  List<WorkPeriod> _findIntersectingPeriods(List<WorkPeriod> periods) {
    if (periods.isEmpty) return [];

    final sorted = [...periods]..sort((a, b) {
      final aMinutes = a.begin.hour * 60 + a.begin.minute;
      final bMinutes = b.begin.hour * 60 + b.begin.minute;
      return aMinutes.compareTo(bMinutes);
    });

    final merged = <WorkPeriod>[];
    var current = sorted[0];

    for (int i = 1; i < sorted.length; i++) {
      final next = sorted[i];

      if (next.begin.isBefore(current.end)) {
        final newEnd = next.end.isAfter(current.end) ? next.end : current.end;
        current = WorkPeriod(current.begin, newEnd);
      } else {
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);
    return merged;
  }

  DateTime _removeTimeFromDateTime(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
  }

  int _weekdayFromDay(DateTime day) {
    int weekday = day.weekday;
    // Moves sunday from last to first
    if (weekday == 7) {
      weekday = 0;
    }

    return weekday;
  }

  List<DateTime> _getUsedSlotsOnDay(DateTime selectedDay) {
    final allAppointments = [...pending, ...booked];
    return allAppointments
        .where((a) => Utils.isSameDay(a.start.toDate(), selectedDay))
        .map((a) => a.start.toDate().toUtc())
        .toList();
  }

  bool isDayAvailableForAppointments(DateTime day) {
    return weeklySchedule[_weekdayFromDay(day)].isNotEmpty;
  }
}
