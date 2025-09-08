import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatModel {
  String id;
  final List<String> participants;
  final String dek;
  final Timestamp? createdAt;
  final Timestamp? lastMessage;

  ChatModel({
    required this.id,
    this.participants = const [],
    required this.dek,
    this.createdAt,
    this.lastMessage,
  });

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    String? dek,
    Timestamp? createdAt,
    Timestamp? lastMessage,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      dek: dek ?? this.dek,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  factory ChatModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      dek: map['dek'] ?? '',
      createdAt: map['createdAt'] as Timestamp,
      lastMessage: map['lastMessage'] as Timestamp,
    );
  }

  String get otherParticipantId {
    if (participants[0] == FirebaseAuth.instance.currentUser?.uid) {
      return participants[1];
    }

    return participants[0];
  }
}
