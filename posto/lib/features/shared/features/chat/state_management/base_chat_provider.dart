import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/auth/logic/auth_service.dart';
import '../../../../../core/services/cache_service/chat_cache_service/chat_cache_service.dart';
import '../../../../../core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import '../../../../../core/services/notification_service/notification_service.dart';
import '../models/chat_model.dart';
import '../models/chat_view_model.dart';
import 'base_chat_state.dart';
import '../logic/chat_service.dart';

part 'base_chat_provider.g.dart';

// ToDo add encryption
// ToDo add way for professional to start chat
// ToDo add push notifications
@riverpod
class BaseChatNotifier extends _$BaseChatNotifier {
  late final ChatCacheService _chatCacheService = ref.read(chatCacheServiceProvider(AuthService.getUserUid()!).notifier);
  late final ProfileCacheService _profileCacheService = ref.read(profileCacheServiceProvider.notifier);
  late final ChatService _chatService = ref.read(chatServiceProvider);

  String? _tempChatProfileId;
  ChatModel? _tempChat;
  String? _tempChatId;

  String? _openChatIdOnLoad;

  KeepAliveLink? _link;

  @override
  BaseChatState build(String userUid) {
    print('Building base chat for user $userUid');

    _link = ref.keepAlive();
    ref.onDispose(() => _link?.close());
    ref.onDispose(() async {
      await closeAllConnections();
    });

    ref.listen(notificationServiceProvider, (oldSate, newState) {
      if (state.selectedChatId == null) {
        return;
      }

      if (newState.chatNotifications.containsKey(state.selectedChatId)) {
        print('DETECTADO NOTIFICACAO COM CHAT ATIVO');
        _removeChatNotifications(state.selectedChatId!);
      }
    });

    return BaseChatState(isLoading: true);
  }

  Future<void> closeAllConnections() async {
    await _chatService.closeAllConnections();

    state = state.copyWith(
      selectedChatId: null,
    );
  }

  void setOpenChatIdOnLoad(String chatId) {
    _openChatIdOnLoad = chatId;
  }

  void createChatsStream() async {
    _chatService.createChatsStream(
      onFirstLoad: (chats) async {
        print('On First load chats');
        for (ChatModel chat in chats) {
          if (chat.id == _tempChatId) {
            print('Temp chat already exists, clearing it and opening it');
            clearTempChat();
            state = state.copyWith(selectedChatId: null);
            await openChat(_chatCacheService.getChat(chat.id)!);
          }
        }
      },
      onData: (chats) async {
        if (_openChatIdOnLoad != null && _chatCacheService.isChatInCache(_openChatIdOnLoad!)) {
          print('Trying to open chat');
          await openChat(_chatCacheService.getChat(_openChatIdOnLoad)!);
          _openChatIdOnLoad = null;
        }

        state = state.copyWith(
          chats: _chatCacheService.getSortedChats(),
          isLoading: false,
        );
      },
      onError: (o, st) async {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  T? getProfileFromChatId<T>(String? chatId) {
    final chat = _chatCacheService.getChat(chatId);

    if (chat == null) {
      return null;
    }

    return _profileCacheService.getProfile(chat.chat.otherParticipantId);
  }

  Future<void> createChat(String participantId) async {
    state = state.copyWith(isLoading: true);

    try {
      await _chatService.createChat(participantId);
      // Stops loading on onData of chat stream
    } catch (e, st) {
      print('Error while creating chat: $e\n$st');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> openChat(ChatViewModel chat) async {
    if (state.isLoadingMessages || state.isLoadingMoreMessages) {
      print('Tried to open another chat while current one is being loaded');
      return;
    }

    final chatId = chat.id;
    if (chatId == state.selectedChatId) {
      print('Trying to open a chat that is already selected');
      return;
    }

    // Pauses last chat subscription
    if (state.selectedChatId != null) {
      print('Pausing chat');
      _chatService.pauseChat(state.selectedChatId!);
    }

    // Resume old chat subscription if it exists
    if (_chatService.resumeChat(chatId)) {
      print('Resuming chat');
      state = state.copyWith(
        chats: _chatCacheService.getSortedChats(),
        selectedChatId: chatId,
        isLoadingMessages: false,
      );
      return;
    }

    // Simulates opening a temporary chat subscription
    if (_tempChatId != null) {
      if (_tempChatId == chatId) {
        print('Simulating opening temp chat');
        state = state.copyWith(
          chats: _chatCacheService.getSortedChats(),
          selectedChatId: _tempChatId,
          isLoadingMessages: false,
        );
        return;
      }
    }

    state = state.copyWith(selectedChatId: chatId, isLoadingMessages: true);

    _chatService.createMessagesStream(
      chat,
      onData: (chats) async {
        _removeChatNotifications(chatId);

        state = state.copyWith(
          chats: chats,
          isLoadingMessages: false,
        );
      },
      onError: (e, st) async {
        state = state.copyWith(
          chats: _chatCacheService.getSortedChats(),
          selectedChatId: null,
          isLoadingMessages: false,
        );
      }
    );
  }

  Future<void> loadMoreMessages() async {
    if (state.selectedChatId == null) return;
    if (state.isLoadingMoreMessages) return;

    final chat = _chatCacheService.getChat(state.selectedChatId!)!;
    if (!chat.canLoadMoreMessages) return;

    print('Fetching more messages');
    state = state.copyWith(isLoadingMoreMessages: true);
    await _chatService.loadMoreMessages(chat);

    state = state.copyWith(
      chats: _chatCacheService.getSortedChats(),
      isLoadingMoreMessages: false,
    );
  }

  Future<void> _removeChatNotifications(String chatId) async {
    Map<String, dynamic> notifications = ref.read(notificationServiceProvider).chatNotifications;

    if (notifications.containsKey(chatId)) {
      return ref.read(notificationServiceProvider.notifier).removeChatNotifications(chatId);
    }
  }

  Future<void> _createTempChatIfNeeded(String chatId) async {
    if (_tempChatId == null) return;
    if (chatId != _tempChatId) return;

    // Saves temp chat ID to prevent it from being erased after chat creation
    final String tempChatId = _tempChatId!;

    print('Creating temp chat');
    await createChat(_tempChatProfileId!);

    // Wait chat creation
    final timeLimitStopwatch = Stopwatch()..start();
    while (!_chatCacheService.isChatInCache(tempChatId)) {
      if (timeLimitStopwatch.elapsed > Duration(seconds: 5)) {
        break;
      }

      await Future.delayed(Duration(milliseconds: 50));
    }
    timeLimitStopwatch.stop();

    final chat = _chatCacheService.getChat(tempChatId);

    if (chat == null) {
      // ToDo show error
      print('Error creating temp chat');
      return;
    }

    state = state.copyWith(selectedChatId: null);
    clearTempChat();
    await openChat(chat);
  }

  bool canSendMessage() {
    final chatId = state.selectedChatId;
    if (chatId == null) return false;

    final chat = _chatCacheService.getChat(chatId)!;
    return chat.isReady;
  }

  Future<void> sendMessage(String message) async {
    final chatId = state.selectedChatId;

    await _createTempChatIfNeeded(chatId!);

    state = state.copyWith(isLoadingMessages: true);

    print('Sending message');
    try {
      await _chatService.sendMessage(chatId, message);
    } catch (e, st) {
      print('Error sending message: $e');
      print(st);
      state = state.copyWith(isLoadingMessages: false);
    }
  }

  Future<void> setTempChat(dynamic profile) async {
    print('Setting temp chat');

    final String? oldTempChatId = _tempChatId;

    // Calculates id of chat
    _tempChatProfileId = profile.id;
    _tempChatId = _chatService.calculateChatId(profile.id);

    // Remove old temp chat from cache
    if (_tempChatId != oldTempChatId && oldTempChatId != null) {
      print('Removing old temp chat');
      _chatCacheService.removeChat(_tempChatId);
    }

    if (_chatCacheService.isChatInCache(_tempChatId!)) {
      String chatId = _tempChatId!;

      if (await _chatService.doesTempChatAlreadyExists(_tempChatId!)) {
        print('Detected temp chat that already exists, opening instead');
        clearTempChat();
      }

      await openChat(_chatCacheService.getChat(chatId)!);
      return;
    }

    // Create chat model
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _tempChat = ChatModel(
      id: _tempChatId!,
      participants: [uid, profile.id],
      dek: '',
      createdAt: Timestamp.now(),
      lastMessage: Timestamp.now(),
    );

    // Cache chat and profile
    _profileCacheService.addProfile(profile.id, profile);
    _chatCacheService.addChat(ChatViewModel(chat: _tempChat!, decryptedDek: ''));

    state = state.copyWith(
      chats: _chatCacheService.getSortedChats(),
      selectedChatId: _tempChatId!,
      isLoadingMessages: false,
    );
  }

  void clearTempChat() {
    _tempChat = null;
    _tempChatId = null;
    _tempChatProfileId = null;
  }

  ChatViewModel? getSelectedChat() {
    return _chatCacheService.getChat(state.selectedChatId);
  }
}
