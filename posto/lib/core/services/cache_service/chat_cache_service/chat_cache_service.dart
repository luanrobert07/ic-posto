import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../features/shared/features/chat/models/chat_view_model.dart';
import '../../../../features/shared/features/chat/models/chat_model.dart';
import '../../../../features/shared/features/chat/models/message_model.dart';
import '../../../../features/shared/features/chat/models/message_view_model.dart';

part 'chat_cache_service.g.dart';

@Riverpod(keepAlive: true)
class ChatCacheService extends _$ChatCacheService {
  @override
  Map<String, ChatViewModel> build(String userId) {
    return {};
  }

  void addChats(List<ChatModel> newChats) {
    final updatedState = Map<String, ChatViewModel>.from(state);

    for (ChatModel chat in newChats) {
      if (state.containsKey(chat.id)) {
        updatedState[chat.id]!.chat = chat;
      } else {
        updatedState[chat.id] = ChatViewModel(chat: chat);
      }
    }

    state = updatedState;
  }

  /// adds chat to cache, overwrites if already on cache
  void addChat(ChatViewModel chat) {
    final updatedState = Map<String, ChatViewModel>.from(state);

    updatedState[chat.id] = chat;

    state = updatedState;
  }

  List<ChatViewModel> getSortedChats() {
    final chats = state.values.toList();
    chats.sort((a, b) => a.chat.lastMessage!.compareTo(b.chat.lastMessage!));
    return chats;
  }

  ChatViewModel? getChat(String? chatId) {
    return state[chatId];
  }

  void removeChat(String? chatId) {
    if (chatId == null) return;
    final updatedState = Map<String, ChatViewModel>.from(state);

    updatedState.remove(chatId);

    state = updatedState;
  }

  bool isChatInCache(String chatId) {
    return state.containsKey(chatId);
  }

  void addMessageSubscription(String chatId, StreamSubscription messageSubscription) {
    final updatedState = Map<String, ChatViewModel>.from(state);

    updatedState[chatId]!.messageSubscription = messageSubscription;

    state = updatedState;
  }

  Future<void> cancelMessageSubscription(String chatId) async {
    final updatedState = Map<String, ChatViewModel>.from(state);

    await updatedState[chatId]!.messageSubscription!.cancel();
    updatedState[chatId]!.messageSubscription = null;

    state = updatedState;
  }

  Future<void> addMessagesToCache(List<MessageModel> messageList, String chatId) async {
    if (messageList.isEmpty) return;

    final updatedState = Map<String, ChatViewModel>.from(state);

    final chat = updatedState[chatId]!;

    final newMessages = messageList.map((message) => MessageViewModel(messageModel: message));

    // Combine existing + new,
    final existingMessages = chat.messageCache;
    final Map<String, MessageViewModel> messageMap = {};
    for (final msg in existingMessages) {
      messageMap[msg.id!] = msg;
    }
    for (final newMsg in newMessages) {
      final existingMsg = messageMap[newMsg.id];

      if (existingMsg == null) {
        messageMap[newMsg.id!] = newMsg;
        continue;
      }

      if (newMsg.messageModel.data['data'] == existingMsg.messageModel.data['data']) {
        messageMap[newMsg.id!] = MessageViewModel(
          messageModel: newMsg.messageModel,
          decryptedMessage: existingMsg.decryptedMessage,
        );
        continue;
      }

      messageMap[newMsg.id!] = newMsg;
    }

    final allMessages = messageMap.values.toList();

    // Sort them again
    allMessages.sort((a, b) {
      final aSent = a.sent;
      final bSent = b.sent;

      if (aSent == null) return -1;
      if (bSent == null) return 1;
      return bSent.compareTo(aSent);
    });

    updatedState[chatId]?.messageCache = allMessages;

    state = updatedState;
  }
}
