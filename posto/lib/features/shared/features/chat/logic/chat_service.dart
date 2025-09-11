import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/auth/logic/auth_service.dart';
import '../../../../../core/auth/state_management/user_type.dart';
import '../../../../../core/auth/state_management/user_type_provider.dart';
import '../../../../../core/encryption/encryption_provider.dart';
import '../../../../../core/encryption/encryption_service.dart';
import '../../../../../core/services/cache_service/chat_cache_service/chat_cache_service.dart';
import '../../../../../core/services/cache_service/profile_cache_service/profile_cache_service.dart';
import '../../../../../core/services/firestore_service/firestore_pagination.dart';
import '../../../../../core/services/firestore_service/firestore_service.dart';
import '../../../../../core/utils/cloud_functions_endpoints.dart';
import '../../providers/patient_profile_provider/public_patient_profile_service.dart';
import '../../providers/professional_profile_provider/public_professional_profile_service.dart';
import '../models/chat_model.dart';
import '../models/chat_view_model.dart';
import '../models/message_model.dart';

part 'chat_service.g.dart';

@riverpod
ChatService chatService(Ref ref) {
  return ChatService(ref);
}

class ChatService extends FirestoreService {
  final Ref ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late CollectionReference collection = _db.collection('chats');
  late final encryptionNotifier = ref.read(encryptionNotifierProvider.notifier);
  final EncryptionService encryptionService = EncryptionService();
  DocumentSnapshot? oldestLoadedChat;
  late final ChatCacheService _chatCacheService = ref.read(chatCacheServiceProvider(AuthService.getUserUid()!).notifier);
  late final ProfileCacheService _profileCacheService = ref.read(profileCacheServiceProvider.notifier);
  StreamSubscription? _chatsSubscription;
  bool _isFirstLoadingChats = true;

  ChatService(this.ref);

  Future<void> createChatsStream({
    Future<void> Function(List<ChatModel> chats)? onFirstLoad,
    Future<void> Function(List<ChatModel> chats)? onData,
    Future<void> Function(Object error, StackTrace stack)? onError,
  }) async {
    if (_chatsSubscription != null) {
      print('Tried to create more than one chat stream');
      return;
    }

    print('Opening chats listener');
    try {
      _chatsSubscription = _streamChats().listen((chats) async {
        print('Received chats update');

        _chatCacheService.addChats(chats);
        await _fetchProfiles(chats);

        if (_isFirstLoadingChats) {
          _isFirstLoadingChats = false;
          if (onFirstLoad != null) await onFirstLoad(chats);
        }

        if (onData != null) await onData(chats);
      }, onError: (error, stack) async {
        print('Error in chat stream: $error\n$stack');
        if (onError != null) await onError(error, stack);
      });
    } catch (e, st) {
      print('Caught sync error while starting chat stream: $e\n$st');
      if (onError != null) await onError(e, st);
    }
  }

  Future<List<ChatModel>> loadMoreChats() async {
    return pagination.loadItems(
      collection
          .where('participants', arrayContains: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('sent', descending: true),
      'chats',
      ChatModel.fromMap,
    );
  }

  Future<void> createChat(String recipientId) async {
    final chatId = await createChatAPI(recipientId, ' ');

    final chat = ChatViewModel(
      chat: ChatModel(
        id: chatId,
        dek: ' ',
        createdAt: Timestamp.now(),
        lastMessage: Timestamp.now(),
      ),
      decryptedDek: ' ',
    );

    _chatCacheService.addChat(chat);
  }

  void pauseChat(String chatId) {
    _chatCacheService.getChat(chatId)?.messageSubscription?.pause();
  }

  /// Resume chat and return true for success and false if no
  /// message subscription was available
  bool resumeChat(String chatId) {
    if (_chatCacheService.getChat(chatId)?.messageSubscription == null) {
      return false;
    }

    _chatCacheService.getChat(chatId)?.messageSubscription?.resume();
    return true;
  }

  Future<void> createMessagesStream(ChatViewModel chat, {
    Future<void> Function(List<ChatViewModel> messages)? onData,
    Future<void> Function(Object error, StackTrace stack)? onError,
  }) async {

    print('Opening messages listener');
    try {
      final messageSubscriptions = _streamChatMessages(chat).listen((messages) async {
        print('received message update, length: ${messages.length}');

        await _chatCacheService.addMessagesToCache(messages, chat.id);
        await _decryptChat(chat);

        chat.canLoadMoreMessages = true;

        if (onData != null) await onData(_chatCacheService.getSortedChats());
      }, onError: (error, stack) async {
        print('Error loading messages: $error');

        if (onError != null) await onError(error, stack);

        await _chatCacheService.cancelMessageSubscription(chat.id);
      });

      _chatCacheService.addMessageSubscription(chat.id, messageSubscriptions);
    } catch (e, st) {
      print('Error while creating chat: $e\n$st');
      if (onError != null) await onError(e, st);
    }
  }

  Future<void> loadMoreMessages(ChatViewModel chat) async {
    final newMessages = await pagination.loadItems(
      collection.doc(chat.id).collection('messages')
          .orderBy('sent', descending: true),
      chat.id,
      MessageModel.fromMap,
    );

    print('Fetched ${newMessages.length} more messages');

    if (newMessages.length < FirestorePagination.pageSize) {
      chat.canLoadMoreMessages = false;
    }

    await _chatCacheService.addMessagesToCache(newMessages, chat.id);
    await _decryptChat(chat);
  }

  Future<void> sendMessage(String chatId, String message) async {
    final chat = _chatCacheService.getChat(chatId)!;

    // User should not send a chat message if the dek hasn't been loaded yet
    if (!chat.isReady) return;

    // ToDo add encryption
    final encryptedData = {
      'data': message,
    };

    return sendChatMessageAPI(chat.id, encryptedData);
  }

  String calculateChatId(String otherParticipant) {
    String chatId = '';

    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (ref.read(userTypeNotifierProvider) == UserType.professional) {
      chatId = '${otherParticipant}_$uid';
    } else {
      chatId = '${uid}_$otherParticipant';
    }

    return chatId;
  }

  Future<void> closeAllConnections() async {
    final List<Future<dynamic>> futures = [];
    final chatsCache = ref.read(chatCacheServiceProvider(AuthService.getUserUid()!));

    for (final chat in chatsCache.values) {
      if (chat.messageSubscription != null) {
        futures.add(chat.messageSubscription!.cancel());
      }
    }

    await Future.wait(futures);

    for (final chat in chatsCache.values) {
      if (chat.messageSubscription != null) {
        chat.messageSubscription = null;
      }
    }

    if (_chatsSubscription != null) {
      futures.add(_chatsSubscription!.cancel());
    }

    await Future.wait(futures);

    _chatsSubscription = null;

    print('Successfully closed all chat connections');
  }

  Future<bool> doesTempChatAlreadyExists(String chatId) async {
    try {
      final docSnapshot = await collection
          .doc(chatId)
          .get();

      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }

  Stream<List<ChatModel>> _streamChats() {
    return pagination.streamItems(
      collection
          .where('participants', arrayContains: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('lastMessage', descending: true),
      'chats',
      ChatModel.fromMap,
    );
  }

  Stream<List<MessageModel>> _streamChatMessages(ChatViewModel chat, {int limit = 10}) {
    return pagination.streamItems(
      collection.doc(chat.id).collection('messages')
          .orderBy('sent', descending: true),
      chat.id,
      MessageModel.fromMap,
    );
  }

  Future<void> _decryptChat(ChatViewModel chat) async {
    // ToDo add decryption
    for (final message in chat.messageCache) {
      message.decryptedMessage ??= message.messageModel.data['data']!;
    }
    chat.decryptedDek = ' ';
  }

  Future<void> _fetchProfiles(List<ChatModel> newChats) async {
    final profileIds = newChats.map((chat) => chat.otherParticipantId).toSet().toList();

    // Check for profiles that are already cached and remove before fetching from server
    final profileCache = ref.read(profileCacheServiceProvider);
    final missingIds = profileIds.where((id) => !profileCache.containsKey(id)).toList();

    if (missingIds.isEmpty) return;

    final userType = ref.read(userTypeNotifierProvider);
    Map<String, dynamic> profiles;
    if (userType == UserType.patient) {
      profiles = await ref.read(publicProfessionalProfileServiceProvider).getMultipleProfilesFromIds(profileIds);
    } else if (userType == UserType.professional) {
      profiles = await ref.read(publicPatientProfileServiceProvider).getMultipleProfilesFromIds(profileIds);
    } else {
      throw Exception('Wrong user type: $userType');
    }

    _profileCacheService.addProfiles(profiles);
  }
}
