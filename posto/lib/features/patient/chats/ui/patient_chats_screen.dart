import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../core/services/notification_service/notification_state.dart';
import '../../../shared/features/chat/ui/chat_list.dart';
import '../../../shared/features/chat/ui/message_list.dart';
import '../../../shared/screens/base_page.dart';
import '../state_management/patient_chats_provider.dart';
import '../state_management/patient_chats_state.dart';

class PatientChatsScreen extends ConsumerStatefulWidget {
  const PatientChatsScreen({
    super.key,
  });

  @override
  ConsumerState<PatientChatsScreen> createState() => _PatientChatsScreenState();
}

class _PatientChatsScreenState extends ConsumerState<PatientChatsScreen> {
  late PatientChatsState state;
  late PatientChatsNotifier notifier;
  late NotificationState notifications;

  @override
  void dispose() {
    super.dispose();

    notifier.closeAllConnections();
  }

  @override
  Widget build(BuildContext context) {
    final String uid = AuthService.getUserUid()!;
    state = ref.watch(patientChatsNotifierProvider(uid));
    notifier = ref.read(patientChatsNotifierProvider(uid).notifier);
    notifications = ref.watch(notificationServiceProvider);

    return BasePage(
      webPage: webPage(),
      mobilePage: mobilePage(),
    );
  }

  Widget webPage() {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        ChatList(
          chatList: state.chats,
          selectedChatId: state.selectedChatId,
          notifications: notifications.chatNotifications,
          getChatName: (chat) {
            final profile = notifier.getProfileFromChatId(chat.id);
            if (profile == null) {
              return 'loading';
            }

            return profile.name;
          },
          onTap: (chat) async {
            await notifier.openChat(chat);
          },
        ),
        MessageList(
          chat: notifier.getSelectedChat(),
          isLoadingMessages: state.isLoadingMessages,
          messageTextController: state.messageTextController,
          title: notifier.getProfileFromChatId(state.selectedChatId)?.name ?? 'Loading',
          isLoadingMoreMessages: state.isLoadingMoreMessages,
          fetchMoreData: () async {
            await notifier.loadMoreMessages();
          },
          onSend: () async {
            await notifier.sendMessage();
          },
        ),
      ],
    );
  }

  Widget mobilePage() {
    return Placeholder();
  }
}
