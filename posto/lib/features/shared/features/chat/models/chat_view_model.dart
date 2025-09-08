import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_model.dart';
import 'message_view_model.dart';

class ChatViewModel {
  ChatModel chat;
  List<MessageViewModel> messageCache;
  StreamSubscription? messageSubscription;
  String? decryptedDek;
  bool canLoadMoreMessages;

  ChatViewModel({
    required this.chat,
    this.messageCache = const [],
    this.messageSubscription,
    this.decryptedDek,
    this.canLoadMoreMessages = false,
  });

  String get id => chat.id;

  bool get isReady => decryptedDek != null;
}
