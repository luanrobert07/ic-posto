import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_model.dart';

class MessageViewModel {
  final MessageModel messageModel;
  String? decryptedMessage;

  MessageViewModel({
    required this.messageModel,
    this.decryptedMessage,
  });

  String? get id => messageModel.id;
  Timestamp? get sent => messageModel.sent;
  String get sentBy => messageModel.sentBy;
}
