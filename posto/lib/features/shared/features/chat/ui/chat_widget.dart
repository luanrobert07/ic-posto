import 'package:flutter/material.dart';

import '../../../../../core/utils/utils.dart';
import 'button_card.dart';
import '../models/chat_view_model.dart';

class ChatWidget extends StatelessWidget {
  final ChatViewModel chat;
  final String name;
  final bool isSelected;
  final int newMessages;
  final void Function() onTap;

  const ChatWidget({
    super.key,
    required this.chat,
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.newMessages = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ButtonCard(
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
        onTap: onTap,
        padding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    Utils.formatDateTime(chat.chat.lastMessage!.toDate()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (!isSelected && newMessages > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Card(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: Text(
                      newMessages.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
