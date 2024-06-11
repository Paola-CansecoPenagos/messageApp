import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get_it/get_it.dart';

import '../models/chat.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';
import '../services/storage_service.dart';
import '../utils.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,
    );
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatUser.name!,
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
      builder: (context, snapshot) {
        Chat? chat = snapshot.data?.data();
        List<ChatMessage> messages = [];
        if (chat != null && chat.messages != null) {
          messages = _generateChatMessagesList(
            chat.messages!,
          );
        }
        return DashChat(
          messageOptions: const MessageOptions(
            showOtherUsersAvatar: true,
            showTime: true,
          ),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            trailing: [
              _mediaMessageButton(),
              _videoMessageButton(),
              _audioMessageButton(),
            ],
          ),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: messages,
        );
      },
    );
  }
  
Future<void> _sendMessage(ChatMessage chatMessage) async {
  Message message = Message(
    senderID: chatMessage.user.id,
    content: '',
    messageType: MessageType.Text,
    sentAt: Timestamp.now(),
  );

  if (chatMessage.medias?.isNotEmpty ?? false) {
    if (chatMessage.medias!.first.type == MediaType.image) {
      message = Message(
        senderID: chatMessage.user.id,
        content: chatMessage.medias!.first.url,
        messageType: MessageType.Image,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
    } else if (chatMessage.medias!.first.type == MediaType.video) {
      message = Message(
        senderID: chatMessage.user.id,
        content: chatMessage.medias!.first.url,
        messageType: MessageType.Video,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
    }
    else if (chatMessage.medias!.first.type == MediaType.file) {
      message = Message(
        senderID: chatMessage.user.id,
        content: chatMessage.medias!.first.url,
        messageType: MessageType.Video,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
    }
  } else {
      message = Message(
        senderID: chatMessage.user.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
    }

  await _databaseService.sendChatMessage(
    currentUser!.id, otherUser!.id, message
  );
}


List<ChatMessage> _generateChatMessagesList(List<Message> messages) {
  List<ChatMessage> chatMessages = messages.map((m) {
    switch (m.messageType) {
      case MessageType.Image:
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          medias: [
            ChatMedia(
              url: m.content!,
              fileName: "",
              type: MediaType.image,
            ),
          ],
        );
      
      case MessageType.Video:
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          medias: [
            ChatMedia(
              url: m.content!,
              fileName: "",
              type: MediaType.video,
            ),
          ],
        );
      case MessageType.Audio:
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          medias: [
            ChatMedia(
              url: m.content!,
              fileName: "",
              type: MediaType.file,
            ),
          ],
        );
      default:
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          text: m.content!,
          createdAt: m.sentAt!.toDate(),
        );
    }
  }).toList();
  chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return chatMessages;
}



  Widget _videoMessageButton() {
  return IconButton(
    icon: Icon(Icons.videocam, color: Theme.of(context).colorScheme.primary),
    onPressed: () async {
      File? videoFile = await _mediaService.getVideoFromGallery(); 
      if (videoFile != null) {
        String chatID = generateChatID(
          uid1: currentUser!.id,
          uid2: otherUser!.id,
        );
        String? downloadURL = await _storageService.uploadMediaToChat(
          file: videoFile,
          chatID: chatID,
          mediaType: MediaType.video,
        );
        if (downloadURL != null) {
          ChatMessage chatMessage = ChatMessage(
            user: currentUser!,
            createdAt: DateTime.now(),
            medias: [
              ChatMedia(
                url: downloadURL,
                fileName: videoFile.path.split('/').last, // Nombre del archivo para referencia
                type: MediaType.video,
              )
            ],
          );
          _sendMessage(chatMessage);
        }
      }
    },
  );
}

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String chatID = generateChatID(
            uid1: currentUser!.id,
            uid2: otherUser!.id,
          );
          String? downloadURL = await _storageService.uploadImageToChat(
              file: file, chatID: chatID);
          if (downloadURL != null) {
            ChatMessage chatMessage = ChatMessage(
                user: currentUser!,
                createdAt: DateTime.now(),
                medias: [
                  ChatMedia(
                      url: downloadURL, fileName: "", type: MediaType.image)
                ]);
            _sendMessage(chatMessage);
          }
        }
      },
      icon: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

    Widget _audioMessageButton() {
    return IconButton(
      icon: Icon(Icons.audiotrack, color: Theme.of(context).colorScheme.primary),
      onPressed: () async {
        File? audioFile = await _mediaService.pickAudioFile();
        if (audioFile != null) {
          String chatID = generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
          String? audioURL = await _storageService.uploadAudioToStorage(audioFile: audioFile, chatID: chatID);
          // Aquí puedes hacer algo con la URL del audio, como enviar un mensaje de chat que contenga la URL
        }
      },
    );
  }
}