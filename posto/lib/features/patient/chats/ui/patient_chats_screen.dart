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
  const PatientChatsScreen({super.key});

  @override
  ConsumerState<PatientChatsScreen> createState() => _PatientChatsScreenState();
}

class _PatientChatsScreenState extends ConsumerState<PatientChatsScreen> {
  late PatientChatsState state;
  late PatientChatsNotifier notifier;
  late NotificationState notifications;

  @override
  void dispose() {
    notifier.closeAllConnections();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String uid = AuthService.getUserUid()!;
    state = ref.watch(patientChatsNotifierProvider(uid));
    notifier = ref.read(patientChatsNotifierProvider(uid).notifier);
    notifications = ref.watch(notificationServiceProvider);

    return BasePage(
      webPage: _webPage(context),
      mobilePage: _mobilePage(),
    );
  }

  Widget _webPage(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE7F1FF), // fundo azul-claro
      child: Center(
        child: Container(
          width: 1000,
          height: 600,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Chat Paciente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ChatList(
                        chatList: state.chats,
                        selectedChatId: state.selectedChatId,
                        notifications: notifications.chatNotifications,
                        getChatName: (chat) {
                          final profile = notifier.getProfileFromChatId(chat.id);
                          return profile?.name ?? 'Carregando...';
                        },
                        onTap: (chat) async {
                          await notifier.openChat(chat);
                        },
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Colors.grey),
                    Expanded(
                      flex: 7,
                      child: MessageList(
                        chat: notifier.getSelectedChat(),
                        isLoadingMessages: state.isLoadingMessages,
                        messageTextController: state.messageTextController,
                        title: notifier
                                .getProfileFromChatId(state.selectedChatId)
                                ?.name ??
                            'Carregando...',
                        isLoadingMoreMessages: state.isLoadingMoreMessages,
                        fetchMoreData: () async {
                          await notifier.loadMoreMessages();
                        },
                        onSend: () async {
                          await notifier.sendMessage();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mobilePage() {
    return const Placeholder();
  }
}
