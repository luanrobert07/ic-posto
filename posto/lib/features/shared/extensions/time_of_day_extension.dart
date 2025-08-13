import 'package:flutter/material.dart';

extension TimeOfDayExtension on TimeOfDay {
  /// Converts to minutes since 00:00
  /// (Ex. 08:30 -> 510)
  int toMinutes() => hour * 60 + minute;

  /// Converts absolute minutes from 00:00 to TimeOfDay
  /// (Ex. 510 -> 08:30)
  static TimeOfDay fromMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return TimeOfDay(hour: h, minute: m);
  }

  TimeOfDay add(Duration duration) {
    int minutes = toMinutes();
    return fromMinutes(minutes + duration.inMinutes);
  }

  TimeOfDay subtract(Duration duration) {
    int minutes = toMinutes();
    return fromMinutes(minutes - duration.inMinutes);
  }

  bool isBeforeOrEqual(TimeOfDay other) {
    if (isAtSameTimeAs(other)) return true;
    return isBefore(other);
  }

  bool isAfterOrEqual(TimeOfDay other) {
    if (isAtSameTimeAs(other)) return true;
    return isAfter(other);
  }
}
