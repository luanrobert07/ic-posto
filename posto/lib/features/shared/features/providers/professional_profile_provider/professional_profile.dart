import 'package:posto/features/shared/features/appointment/models/appointment.dart';

import '../../../../../core/utils/utils.dart';
import '../../../../professional/profile_settings/exceptions_rule_editor/models/exception_rule_model.dart';

class ProfessionalProfile {
  // Public info
  final String id;
  final String name;
  final String contact;
  final Map<String, List<dynamic>> scheduleRules;
  final List<ExceptionRuleModel> scheduleRulesExceptions;
  final int sessionDuration;
  final int timezoneOffset;
  final List<Appointment> bookedAppointments;
  final List<Appointment> pendingAppointments;

  // Private info
  final String? firebaseMessagingToken;
  final List<String> recentRecords;
  final Map<String, dynamic> chatNotifications;

  ProfessionalProfile({
    this.id = '',
    required this.name,
    required this.contact,
    this.scheduleRules = const {},
    this.scheduleRulesExceptions = const [],
    this.sessionDuration = 0,
    this.timezoneOffset = 0,
    this.bookedAppointments = const [],
    this.pendingAppointments = const [],
    this.firebaseMessagingToken,
    this.recentRecords = const [],
    this.chatNotifications = const {},
  });

  factory ProfessionalProfile.empty() {
    return ProfessionalProfile(
      name: '',
      contact: '',
    );
  }

  factory ProfessionalProfile.fromMap(String id, Map<String, dynamic> map) {
    final profile = ProfessionalProfile(
      id: id,
      name: map['name'] ?? '',
      contact: map['contact'] ?? '',
      scheduleRules: Map<String, List<dynamic>>.from(map['scheduleRules'] ?? {}),
      scheduleRulesExceptions: Utils.jsonArrayToList(map['scheduleRulesExceptions'], ExceptionRuleModel().fromJson),
      sessionDuration: map['sessionDuration'] ?? 0,
      timezoneOffset: map['timezoneOffset'] ?? 0,

      firebaseMessagingToken: map['firebaseMessagingToken'],
      bookedAppointments: Utils.jsonArrayToList(map['bookedAppointments'], Appointment.fromJson),
      pendingAppointments: Utils.jsonArrayToList(map['pendingAppointments'], Appointment.fromJson),
      recentRecords: List<String>.from(map['recentRecords'] ?? []),
      chatNotifications: Map<String, dynamic>.from(map['chatNotifications'] ?? {}),
    );

    // ToDo this will probably cause lag if user tries to load 10+ professionals with 100+ appointments each
    profile.bookedAppointments.sort((a, b) => a.start.compareTo(b.start));
    profile.pendingAppointments.sort((a, b) => a.start.compareTo(b.start));
    profile.scheduleRulesExceptions.sort((a, b) {
      final aStart = a.rangeStartDay ?? a.selectedDays?.first;
      final bStart = b.rangeStartDay ?? b.selectedDays?.first;

      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;

      return aStart.compareTo(bStart);
    });

    return profile;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'scheduleRules': scheduleRules,
      'sessionDuration': sessionDuration,
      'timezoneOffset': timezoneOffset,
    };
  }
}
