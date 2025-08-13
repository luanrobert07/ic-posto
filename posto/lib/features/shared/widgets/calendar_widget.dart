import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime? focusedDay;
  final DateTime calendarStartDay;
  final DateTime calendarEndDay;
  final DateTime? rangeStartDay;
  final DateTime? rangeEndDay;
  final bool dayRangeEnable;
  final List<DateTime> highlightDays;
  final void Function(DateTime)? onPageChanged;
  final void Function(DateTime) onDaySelected;
  final bool Function(DateTime day) isDayAvailableForAppointments;

  const CalendarWidget({
    super.key,
    this.focusedDay,
    required this.calendarStartDay,
    required this.calendarEndDay,
    this.rangeStartDay,
    this.rangeEndDay,
    this.dayRangeEnable = false,
    this.highlightDays = const [],
    this.onPageChanged,
    required this.onDaySelected,
    required this.isDayAvailableForAppointments,
  });

  DateTime getOldestDay(DateTime? rangeStartDay, List<DateTime> highlightDays) {
    if (dayRangeEnable) {
      if (rangeStartDay == null) return calendarStartDay;
      if (rangeStartDay.isBefore(calendarStartDay)) return rangeStartDay;
      return calendarStartDay;
    }

    final DateTime? oldestHighlight = highlightDays.isNotEmpty
        ? highlightDays.reduce((a, b) => a.isBefore(b) ? a : b)
        : null;

    if (oldestHighlight == null) return calendarStartDay;

    return oldestHighlight.isBefore(calendarStartDay) ? oldestHighlight : calendarStartDay;
  }

  void onDaySelectedHandler(DateTime day) {
    if (day.isBefore(calendarStartDay)) return;
    onDaySelected(day);
  }

  @override
  Widget build(BuildContext context) {
    final calendarStart = getOldestDay(rangeStartDay, highlightDays);

    return TableCalendar(
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: Theme.of(context).textTheme.bodyMedium!,
        weekendStyle: Theme.of(context).textTheme.bodyMedium!,
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        rangeHighlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
        rangeStartDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape. circle,
          // boxShadow: [
          //   BoxShadow(
          //     color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          //     blurRadius: 8,
          //     spreadRadius: 2,
          //   ),
          // ],
        ),
        rangeEndDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape. circle,
        ),
      ),
      daysOfWeekHeight: 24,
      rowHeight: 52,
      focusedDay: focusedDay ?? DateTime.now(),
      firstDay: calendarStart,
      lastDay: calendarEndDay,
      weekendDays: [DateTime.sunday],
      selectedDayPredicate: (day) {
        if (dayRangeEnable) return false;
        return highlightDays.any((d) => isSameDay(d, day));
      },
      rangeStartDay: dayRangeEnable ? rangeStartDay : null,
      rangeEndDay: dayRangeEnable ? rangeEndDay : null,
      rangeSelectionMode: dayRangeEnable ? RangeSelectionMode.enforced : RangeSelectionMode.disabled,
      onPageChanged: onPageChanged,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          bool isAvailable = isDayAvailableForAppointments(day) && day.isAfter(calendarStartDay);
          return dayWidget(context, day, isAvailable: isAvailable);
        },
        todayBuilder: (context, day, focusedDay) {
          bool isAvailable = isDayAvailableForAppointments(day);
          return dayWidget(context, day, isAvailable: isAvailable, isToday: true);
        },
        selectedBuilder: (context, day, focusedDay) {
          return dayWidget(context, day, isHighlighted: true);
        },
      ),
    );
  }

  Widget dayWidget(BuildContext context, DateTime day, {bool isAvailable = true, bool isHighlighted = false, bool isToday = false}) {
    return GestureDetector(
      onPanDown: (_) {
        onDaySelectedHandler(day);
      },
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isHighlighted ? Theme.of(context).colorScheme.primary : null,
          shape: BoxShape.circle,
          border: isToday ? Border.all(
            color: Theme.of(context).primaryColor,
            width: 2
          ) : null,
        ),
        child: Text(
          '${day.day}',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: isAvailable ? null : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}
