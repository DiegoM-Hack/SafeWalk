import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messages(String alertId) {
    return _firestore
        .collection('emergency_alerts')
        .doc(alertId)
        .collection('messages');
  }

  /// Escucha los mensajes del chat en tiempo real
  Stream<List<ChatMessageModel>> getMessages(String alertId) {
    return _messages(alertId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromDocument(doc))
              .toList(),
        );
  }

  /// Envía cualquier tipo de mensaje
  Future<void> sendMessage(ChatMessageModel message) async {
    await _messages(message.alertId).add(message.toMap());
  }

  /// Elimina un mensaje
  Future<void> deleteMessage({
    required String alertId,
    required String messageId,
  }) async {
    await _messages(alertId).doc(messageId).delete();
  }

  Stream<bool> hasMessages(String alertId) {
  return _firestore
      .collection('emergency_alerts')
      .doc(alertId)
      .collection('messages')
      .limit(1)
      .snapshots()
      .map((snapshot) => snapshot.docs.isNotEmpty);
}
}