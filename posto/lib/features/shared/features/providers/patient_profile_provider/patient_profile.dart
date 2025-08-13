import '../../../../../core/utils/utils.dart';
import '../../appointment/models/appointment.dart';

class PatientProfile {
  final String id;
  final String name;
  final String contact;
  final String? firebaseMessagingToken;
  final List<Appointment> pendingAppointments;
  final List<Appointment> bookedAppointments;
  final Map<String, dynamic> chatNotifications;

  PatientProfile({
    this.id = '',
    required this.name,
    required this.contact,
    this.firebaseMessagingToken,

    this.bookedAppointments = const [],
    this.pendingAppointments = const [],
    this.chatNotifications = const {},
  });

  factory PatientProfile.empty() {
    return PatientProfile(
      name: '',
      contact: '',
    );
  }

  factory PatientProfile.fromMap(String id, Map<String, dynamic> map) {
    final profile = PatientProfile(
      id: id,
      name: map['name'] ?? '',
      contact: map['contact'] ?? '',
      firebaseMessagingToken: map['firebaseMessagingToken'],
      bookedAppointments: Utils.jsonArrayToList(map['bookedAppointments'], Appointment.fromJson),
      pendingAppointments: Utils.jsonArrayToList(map['pendingAppointments'], Appointment.fromJson),
      chatNotifications: Map<String, dynamic>.from(map['chatNotifications'] ?? {}),
    );

    profile.bookedAppointments.sort((a, b) => a.start.compareTo(b.start));
    profile.pendingAppointments.sort((a, b) => a.start.compareTo(b.start));

    return profile;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
    };
  }
}
