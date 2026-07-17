import 'dart:async';

import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  StreamSubscription<List<ChatMessageModel>>? _subscription;

  List<ChatMessageModel> _messages = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<ChatMessageModel> get messages => _messages;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void listenMessages(String alertId) {
    _setLoading(true);

    _subscription?.cancel();

    _subscription = _chatService.getMessages(alertId).listen(
      (messages) {
        _messages = messages;
        _errorMessage = null;
        _setLoading(false);
      },
      onError: (e) {
        _errorMessage = e.toString();
        _setLoading(false);
      },
    );
  }

  Future<bool> sendText({
    required String id,
    required String alertId,
    required String senderUid,
    required String text,
  }) async {
    try {
      final message = ChatMessageModel(

        id: id,
        alertId: alertId,
        senderUid: senderUid,
        message: text,
        type: ChatMessageModel.text,
        createdAt: DateTime.now(),
      );

      await _chatService.sendMessage(message);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendLocation({
    required String alertId,
    required String senderUid,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final message = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        alertId: alertId,
        senderUid: senderUid,
        type: ChatMessageModel.location,
        latitude: latitude,
        longitude: longitude,
        createdAt: DateTime.now(),
      );

      await _chatService.sendMessage(message);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendSystemMessage({
    required String alertId,
    required String text,
  }) async {
    try {
      final message = ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        alertId: alertId,
        senderUid: "system",
        message: text,
        type: ChatMessageModel.system,
        createdAt: DateTime.now(),
      );

      await _chatService.sendMessage(message);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Stream<bool> hasMessages(String alertId) {
  return _chatService.hasMessages(alertId);
}

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}