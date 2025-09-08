import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../widgets/conditional_widget.dart';
import '../../../widgets/infinite_scroll_list.dart';
import '../models/chat_view_model.dart';
import 'message_widget.dart';

class MessageList extends StatelessWidget {
  final ChatViewModel? chat;
  final bool isLoadingMessages;
  final TextEditingController messageTextController;
  final void Function()? onSend;
  final Future<void> Function() fetchMoreData;
  final bool isLoadingMoreMessages;
  final String? title;

  const MessageList({
    super.key,
    this.chat,
    required this.isLoadingMessages,
    required this.messageTextController,
    required this.onSend,
    required this.fetchMoreData,
    required this.isLoadingMoreMessages,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Card(
        margin: EdgeInsets.all(8),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ConditionalWidget(
            condition: chat != null,
            whenFalse: (context) => Center(child: Text('Select a person to start chatting')),
            whenTrue: (context) => Column(
              children: [
                if (title != null)
                  Row(
                    children: [
                      Text(title!),
                    ],
                  ),
                Expanded(
                  child: ConditionalWidget(
                    condition: isLoadingMessages,
                    whenTrue: (context) => const Center(child: CircularProgressIndicator()),
                    whenFalse: (context) => ConditionalWidget(
                      condition: chat!.messageCache.isNotEmpty,
                      whenFalse: (context) => const Center(child: Text('Send a message to start chat')),
                      whenTrue: (context) => InfiniteScrollList(
                        fetchMoreData: fetchMoreData,
                        isLoadingMore: isLoadingMoreMessages,
                        canLoadMore: chat!.canLoadMoreMessages,
                        padding: EdgeInsets.all(14),
                        reverse: true,
                        itemCount: chat!.messageCache.length,
                        itemBuilder: (context, id) {
                          final message = chat!.messageCache[id];

                          return MessageWidget(
                            message: message,
                            isSender: message.sentBy == FirebaseAuth.instance.currentUser?.uid,
                            isLoadingDate: message.sent == null,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (chat!.isReady)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageTextController,
                          onSubmitted: (value) {
                            if (!chat!.isReady) {
                              print('Tried to send message while chat is still loading');
                              return;
                            }

                            if (onSend != null) {
                              onSend!();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: onSend,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
