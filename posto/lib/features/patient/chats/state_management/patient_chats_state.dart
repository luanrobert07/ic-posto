import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/features/chat/models/chat_view_model.dart';

part 'patient_chats_state.freezed.dart';

@freezed
abstract class PatientChatsState with _$PatientChatsState {
  const factory PatientChatsState({
    @Default([]) List<ChatViewModel> chats,
    String? selectedChatId,
    required TextEditingController messageTextController,
    required bool isLoading,
    @Default(false) bool isLoadingMessages,
    @Default(false) bool isLoadingMoreMessages,
  }) = _PatientChatsState;
}
