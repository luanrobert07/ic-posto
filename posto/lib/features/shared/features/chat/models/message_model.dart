import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? id;
  final Map<String, dynamic> data;
  final String sentBy;
  final Timestamp? sent;

  MessageModel({
    this.id,
    required this.data,
    required this.sentBy,
    this.sent,
  });

  MessageModel copyWith({
    String? id,
    Map<String, dynamic>? data,
    String? sentBy,
    Timestamp? sent,
  }) {
    return MessageModel(
      id: id ?? this.id,
      data: data ?? this.data,
      sentBy: sentBy ?? this.sentBy,
      sent: sent ?? this.sent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'sentBy': sentBy,
      'sent': FieldValue.serverTimestamp(),
    };
  }

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      sentBy: map['sentBy'] ?? '',
      sent: map['sent'] as Timestamp?,
    );
  }
}
