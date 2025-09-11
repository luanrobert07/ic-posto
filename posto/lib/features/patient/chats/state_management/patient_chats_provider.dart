import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:posto/features/patient/chats/state_management/patient_chats_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/logic/auth_service.dart';
import '../../../shared/features/chat/models/chat_view_model.dart';
import '../../../shared/features/chat/state_management/base_chat_provider.dart';
import '../../../shared/features/providers/professional_profile_provider/professional_profile.dart';

part 'patient_chats_provider.g.dart';

@riverpod
class PatientChatsNotifier extends _$PatientChatsNotifier {
  BaseChatNotifier? _baseChatNotifier;

  @override
  PatientChatsState build(String userUid) {
    print('Building patient chat for user $userUid');

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

    return PatientChatsState(
      messageTextController: TextEditingController(),
      isLoading: true,
    );
  }

  Future<void> closeAllConnections() async {
    return _baseChatNotifier!.closeAllConnections();
  }

  ProfessionalProfile? getProfileFromChatId(String? chatId) {
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

  Future<void> setTempChat(ProfessionalProfile profile) async {
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
