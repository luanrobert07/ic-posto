import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../shared/screens/base_page.dart';
import '../../../shared/features/chat/ui/chat_list.dart';
import '../../../shared/features/chat/ui/message_list.dart';
import '../state_management/professional_chats_provider.dart';
import '../state_management/professional_chats_state.dart';

class ProfessionalChatsScreen extends ConsumerStatefulWidget {
  const ProfessionalChatsScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfessionalChatsScreenState();
}

class _ProfessionalChatsScreenState extends ConsumerState<ProfessionalChatsScreen> {
  late ProfessionalChatsState state;
  late ProfessionalChatsNotifier notifier;
  Map<String, dynamic> chatNotifications = {};

  @override
  void dispose() {
    super.dispose();

    notifier.closeAllConnections();
  }

  @override
  Widget build(BuildContext context) {
    final String uid = AuthService.getUserUid()!;
    state = ref.watch(professionalChatsNotifierProvider(uid));
    notifier = ref.read(professionalChatsNotifierProvider(uid).notifier);
    chatNotifications = ref.watch(notificationServiceProvider).chatNotifications;

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
          notifications: chatNotifications,
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
