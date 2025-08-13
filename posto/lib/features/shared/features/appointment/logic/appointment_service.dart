import '../../../../professional/profile_settings/base/state_management/work_period.dart';

class AppointmentService {
  List<List<WorkPeriod>> parseSchedule(Map<String, List<dynamic>> scheduleJson) {
    final result = _generateEmptyScheduleList();

    scheduleJson.forEach((key, value) {
      final index = int.tryParse(key);
      if (index != null && index >= 0 && index < 7) {
        result[index] = value.map((str) => WorkPeriod.fromString(str)).toList();
      }
    });

    return result;
  }

  Map<String, List<String>> encodeSchedule(List<List<WorkPeriod>> schedule) {
    final Map<String, List<String>> result = {};

    for (int i = 0; i < schedule.length; i++) {
      final day = schedule[i];
      if (day.isNotEmpty) {
        result[i.toString()] = day.map((wp) => wp.encodeToServer()).toList();
      }
    }

    return result;
  }

  List<List<WorkPeriod>> _generateEmptyScheduleList() {
    return List.generate(7, (_) => []);
  }
}
