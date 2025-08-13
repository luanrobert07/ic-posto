import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:posto/core/utils/utils.dart';

class Appointment {
  final String? patientId;
  final String? professionalId;
  final Timestamp start;
  final Timestamp end;
  final Timestamp? createdAt;
  Timestamp? lastInteractionAt;
  String? status;

  bool hasConflict;

  Appointment({
    this.patientId,
    this.professionalId,
    required this.start,
    required this.end,
    this.createdAt,
    this.lastInteractionAt,
    this.status,

    this.hasConflict = false,
  });

  Appointment copyWith({
    String? patientId,
    String? professionalId,
    Timestamp? start,
    Timestamp? end,
    Timestamp? createdAt,
    Timestamp? lastInteractionAt,
    String? status,
  }) {
    return Appointment(
      patientId: patientId ?? this.patientId,
      professionalId: professionalId ?? this.professionalId,
      start: start ?? this.start,
      end: end ?? this.end,
      createdAt: createdAt ?? this.createdAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      status: status ?? this.status,
    );
  }

  /// For firestore
  Map<String, dynamic> toJson() {
    final json = {
      'patientId': patientId,
      'professionalId': professionalId,
      'start': start.seconds,
      'end': end.seconds,
      'createdAt': createdAt,
    };

    if (lastInteractionAt != null) json['lastInteractionAt'] = lastInteractionAt;
    if (status != null) json['status'] = status;

    return json;
  }

  /// For cloud function endpoint (Timestamp object treated differently from firestore)
  Map<String, dynamic> toCloudFunctionJson() {
    return {
      'patientId': patientId,
      'start': start.seconds,
      'end': end.seconds,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      patientId: json['patientId'] ?? '',
      professionalId: json['professionalId'] ?? '',
      start: Utils.parseTimestamp(json['start'])!,
      end: Utils.parseTimestamp(json['end'])!,
      createdAt: Utils.parseTimestamp(json['createdAt']),
      lastInteractionAt: Utils.parseTimestamp(json['lastInteractionAt']),
      status: json['status'],
    );
  }

  factory Appointment.createRequest(String professionalId, Timestamp start, Timestamp end) {
    return Appointment(
      professionalId: professionalId,
      start: start,
      end: end,
    );
  }
}
