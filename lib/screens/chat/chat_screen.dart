import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/chat_provider.dart';
import '../../providers/location_provider.dart';

class ChatScreen extends StatefulWidget {
  final String alertId;
  final String uid;

  const ChatScreen({super.key, required this.alertId, required this.uid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().listenMessages(widget.alertId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await context.read<ChatProvider>().sendText(
      id: widget.uid,
      alertId: widget.alertId,
      senderUid: _uid,
      text: text,
    );

    _messageController.clear();
  }

  Future<void> _shareLocation() async {
    final locationProvider = context.read<LocationProvider>();
    final chatProvider = context.read<ChatProvider>();

    await locationProvider.loadCurrentLocation();

    if (!mounted) return;

    final position = locationProvider.currentPosition;
    if (position == null) return;

    await chatProvider.sendLocation(
      alertId: widget.alertId,
      senderUid: _uid,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('emergency_alerts')
              .doc(widget.alertId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Chat de emergencia");
            }

            final alertData = snapshot.data!.data() ?? {};
            final userName = alertData['userName'] ?? 'Contacto en emergencia';
            final userPhoto = alertData['userPhoto'] ?? '';

            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: (userPhoto.isNotEmpty)
                      ? NetworkImage(userPhoto)
                      : null,
                  child: userPhoto.isEmpty
                      ? const Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    userName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages[index];
                      final isMe = message.senderUid == _uid;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message.type == "text")
                                Text(
                                  message.message ?? "",
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),

                              if (message.type == "location")
                                InkWell(
                                  onTap: () async {
                                    final url = Uri.parse(
                                      "https://www.google.com/maps/search/?api=1&query="
                                      "${message.latitude},${message.longitude}",
                                    );

                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? Colors.blue.shade300
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: isMe
                                              ? Colors.white
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Ubicación compartida\n(Toca para abrir Maps)",
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.location_on),
                  tooltip: "Compartir ubicación",
                  onPressed: _shareLocation,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
