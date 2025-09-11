import 'package:flutter/cupertino.dart';
import 'package:posto/features/professional/chats/state_management/professional_chats_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../shared/features/chat/models/chat_view_model.dart';
import '../../../shared/features/chat/state_management/base_chat_provider.dart';
import '../../../shared/features/providers/patient_profile_provider/patient_profile.dart';

part 'professional_chats_provider.g.dart';

@riverpod
class ProfessionalChatsNotifier extends _$ProfessionalChatsNotifier {
  BaseChatNotifier? _baseChatNotifier;

  @override
  ProfessionalChatsState build(String userUid) {
    print('Building professional chat for user $userUid');

    final String uid = AuthService.getUserUid()!;
    _baseChatNotifier ??= ref.read(baseChatNotifierProvider(uid).notifier);

    final baseChatListener = ref.listen(baseChatNotifierProvider(uid), (oldState, newState) {
      state = state.copyWith(
        chats: newState.chats,
        selectedChatId: newState.selectedChatId,
        isLoading: newState.isLoading,
        isLoadingMessages: newState.isLoadingMessages,
        isLoadingMoreMessages: newState.isLoadingMoreMessages,
      );
    });
    ref.onDispose(() => baseChatListener.close());

    Future.microtask(() => _baseChatNotifier!.createChatsStream());

    return ProfessionalChatsState(
      messageTextController: TextEditingController(),
      isLoading: true,
    );
  }

  Future<void> closeAllConnections() async {
    return _baseChatNotifier!.closeAllConnections();
  }

  PatientProfile? getProfileFromChatId(String? chatId) {
    return _baseChatNotifier!.getProfileFromChatId(chatId);
  }

  Future<void> openChat(ChatViewModel chat) async {
    return _baseChatNotifier!.openChat(chat);
  }

  Future<void> sendMessage() async {
    if (!_baseChatNotifier!.canSendMessage()) return;

    final message = state.messageTextController.text.trim();

    if (message.isEmpty) return;

    state.messageTextController.text = '';
    state = state.copyWith(isLoadingMessages: true);

    return _baseChatNotifier!.sendMessage(message);
  }

  Future<void> setTempChat(PatientProfile profile) async {
    return _baseChatNotifier!.setTempChat(profile);
  }

  void clearTempChat() {
    _baseChatNotifier!.clearTempChat();
  }

  Future<void> loadMoreMessages() async {
    return _baseChatNotifier!.loadMoreMessages();
  }

  ChatViewModel? getSelectedChat() {
    return _baseChatNotifier!.getSelectedChat();
  }
}
