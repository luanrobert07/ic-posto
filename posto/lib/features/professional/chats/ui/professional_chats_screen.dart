import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../shared/screens/base_page.dart';
import '../../../shared/features/chat/ui/chat_list.dart';
import '../../../shared/features/chat/ui/message_list.dart';
import '../state_management/professional_chats_provider.dart';
import '../state_management/professional_chats_state.dart';

class ProfessionalChatsScreen extends ConsumerStatefulWidget {
  const ProfessionalChatsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfessionalChatsScreenState();
}

class _ProfessionalChatsScreenState
    extends ConsumerState<ProfessionalChatsScreen> {
  late ProfessionalChatsState state;
  late ProfessionalChatsNotifier notifier;
  Map<String, dynamic> chatNotifications = {};

  @override
  void dispose() {
    notifier.closeAllConnections();
    super.dispose();
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
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF3FA), Color(0xFFD9ECF8)],
        ),
      ),
      child: Center(
        child: Container(
          width: 0.75 * MediaQuery.of(context).size.width,
          height: 0.85 * MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Cabeçalho com botão voltar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF2E7FA3)),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Chat Médico',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7FA3),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Row(
                  children: [
                    // Lista de conversas (ChatList)
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F9FC),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                        child: ChatList(
                          chatList: state.chats,
                          selectedChatId: state.selectedChatId,
                          notifications: chatNotifications,
                          getChatName: (chat) {
                            final profile =
                                notifier.getProfileFromChatId(chat.id);
                            if (profile == null) return 'Carregando...';
                            return profile.name;
                          },
                          onTap: (chat) async {
                            await notifier.openChat(chat);
                          },
                        ),
                      ),
                    ),
                    // Área de mensagens (MessageList)
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20),
                          ),
                        ),
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

  Widget mobilePage() {
    return Container(
      color: const Color(0xFFEAF3FA),
      child: const Center(
        child: Text(
          'Versão mobile em desenvolvimento',
          style: TextStyle(color: Color(0xFF2E7FA3)),
        ),
      ),
    );
  }
}
