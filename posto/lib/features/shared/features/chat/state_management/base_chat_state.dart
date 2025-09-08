import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/chat_view_model.dart';

part 'base_chat_state.freezed.dart';

@freezed
abstract class BaseChatState with _$BaseChatState {
  const factory BaseChatState({
    @Default([]) List<ChatViewModel> chats,
    String? selectedChatId,
    required bool isLoading,
    @Default(false) bool isLoadingMessages,
    @Default(false) bool isLoadingMoreMessages,
  }) = _BaseChatState;
}
