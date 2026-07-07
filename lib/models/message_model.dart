class MessageModel {
  final String senderId;
  final String message;
  final DateTime date;

  MessageModel({
    required this.senderId,
    required this.message,
    required this.date,
  });
}