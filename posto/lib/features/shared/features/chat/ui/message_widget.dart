import 'package:flutter/material.dart';
import '../../../widgets/conditional_widget.dart';
import '../models/message_view_model.dart';

class MessageWidget extends StatelessWidget {
  final MessageViewModel message;
  final bool isSender;
  final bool isLoadingDate;

  const MessageWidget({
    super.key,
    required this.message,
    required this.isSender,
    required this.isLoadingDate,
  });

  @override
  Widget build(BuildContext context) {
    final Color senderColor = Colors.blue.shade100;
    final Color receiverColor = Colors.grey.shade200;

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSender ? senderColor : receiverColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isSender ? 14 : 0),
            bottomRight: Radius.circular(isSender ? 0 : 14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ConditionalWidget(
          condition: message.decryptedMessage == null,
          whenTrue: (context) => const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          whenFalse: (context) => Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.decryptedMessage!,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              if (isLoadingDate)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (!isLoadingDate)
                Text(
                  _formatDate(message.sent?.toDate()),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
