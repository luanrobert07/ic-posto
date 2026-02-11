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
    final chats = chatList.reversed.toList();

    return Expanded(
      flex: 2,
      child: Card(
        margin: const EdgeInsets.all(8),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade300),
          itemBuilder: (context, index) {
            final chat = chats[index];
            final isSelected = chat.id == selectedChatId;
            final notifCount = notifications?[chat.id] ?? 0;

            return InkWell(
              onTap: () async => await onTap(chat),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.blue.shade200,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        getChatName(chat),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.blue.shade900 : Colors.black87,
                        ),
                      ),
                    ),
                    if (notifCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notifCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
