import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/firebase_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> sendMessage({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String message,
  }) async {
    try {
      String chatId = _firebaseService.getChatId(senderId, receiverId);

      MessageModel messageModel = MessageModel(
        id: '',
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
      );

      await _firebaseService.sendMessage(messageModel);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<MessageModel>> getMessages(String userId, String otherUserId) {
    String chatId = _firebaseService.getChatId(userId, otherUserId);
    return _firebaseService.getMessages(chatId);
  }

  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firebaseService.getUserChats(userId);
  }

  Future<void> markMessagesAsRead(String userId, String otherUserId) async {
    String chatId = _firebaseService.getChatId(userId, otherUserId);
    await _firebaseService.markMessagesAsRead(chatId, userId);
  }
}