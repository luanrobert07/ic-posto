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
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        margin: EdgeInsets.all(5),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ConditionalWidget(
            condition: message.decryptedMessage == null,
            whenTrue: (BuildContext context) => CircularProgressIndicator(),
            whenFalse: (BuildContext context) => Column(
              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.decryptedMessage!,
                  maxLines: null,
                  softWrap: true,
                ),

                if (isLoadingDate)
                  CircularProgressIndicator(),

                if (!isLoadingDate)
                  Text(
                    message.sent?.toDate().toString() ?? 'No timestamp available',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
