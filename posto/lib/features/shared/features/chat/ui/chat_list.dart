import 'package:flutter/material.dart';

import '../models/chat_view_model.dart';
import 'chat_widget.dart';

class ChatList extends StatelessWidget {
  final List<ChatViewModel> chatList;
  final String? selectedChatId;
  final String Function(ChatViewModel) getChatName;
  final Function(ChatViewModel) onTap;
  final Map<String, dynamic>? notifications;

  const ChatList({
    super.key,
    required this.chatList,
    this.selectedChatId,
    required this.getChatName,
    required this.onTap,
    this.notifications = const {},
  });

  @override
  Widget build(BuildContext context) {
    final chatList = this.chatList.reversed.toList();

    return Expanded(
      flex: 2,
      child: Card(
        margin: EdgeInsets.all(8),
        elevation: 6,
        child: ListView.builder(
          itemCount: chatList.length,
          itemBuilder: (context, id) {
            final chat = chatList[id];
            final isSelected = chat.id == selectedChatId;

            final Map<String, dynamic> notifications = this.notifications ?? {};

            return ChatWidget(
              chat: chat,
              name: getChatName(chat),
              isSelected: isSelected,
              newMessages: notifications.containsKey(chat.id) ? notifications[chat.id]! : 0,
              onTap: () async {
                await onTap(chat);
              },
            );
          },
        ),
      ),
    );
  }
}
