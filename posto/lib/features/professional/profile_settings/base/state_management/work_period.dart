import 'package:flutter/material.dart';
import 'package:posto/features/shared/extensions/time_of_day_extension.dart';

class WorkPeriod {
  TimeOfDay begin;
  TimeOfDay end;
  bool isUtc = false;

  WorkPeriod(this.begin, this.end);

  WorkPeriod.empty()
      : begin = const TimeOfDay(hour: 0, minute: 0),
        end = const TimeOfDay(hour: 0, minute: 0);

  factory WorkPeriod.fromString(String str) {
    final splitStr = str.split('-');

    final start = int.tryParse(splitStr[0]);
    final end = int.tryParse(splitStr[1]);

    if (start == null || end == null) throw Exception('Could not parse work period from string');

    final workPeriod = WorkPeriod(
      TimeOfDayExtension.fromMinutes(start),
      TimeOfDayExtension.fromMinutes(end),
    );

    return workPeriod;
  }

  @override
  String toString() {
    return '${begin.toMinutes()}-${end.toMinutes()}';
  }

  String encodeToServer() {
    return toString();
  }

  void toUtc() {
    if (isUtc) return;
    final Duration offset = DateTime.now().timeZoneOffset;
    begin = begin.subtract(offset);
    end = end.subtract(offset);
    isUtc = true;
  }

  void fromUtc() {
    if (!isUtc) return;
    final Duration offset = DateTime.now().timeZoneOffset;
    begin = begin.add(offset);
    end = end.add(offset);
    isUtc = false;
  }

  bool isValid() {
    return end.isAfter(begin);
  }
}
