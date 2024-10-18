import 'package:chat_app/widgets/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key, required this.receiverId});
  final receiverId;
  @override
  Widget build(BuildContext context) {
    final authenticatinguser = FirebaseAuth.instance.currentUser;
    final chatId = authenticatinguser!.uid.compareTo(receiverId) < 0
        ? '${authenticatinguser.uid}_${receiverId}'
        : '${receiverId}_${authenticatinguser.uid}';
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .doc(chatId)
            .collection('messages')
            .orderBy(descending: true, 'createdAt')
            .snapshots(),
        builder: (context, chatsnapshot) {
          if (chatsnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatsnapshot.hasData || chatsnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No messages found"),
            );
          }
          if (chatsnapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }
          final loadedmessages = chatsnapshot.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(left: 13, bottom: 40, right: 13),
              reverse: true,
              itemCount: loadedmessages.length,
              itemBuilder: (context, index) {
                final ChatMessage = loadedmessages[index];
                final nextMessage = index + 1 < loadedmessages.length
                    ? loadedmessages[index + 1]
                    : null;
                final currentUserId = ChatMessage['user_id'];
                final nextUserId =
                    nextMessage == null ? null : nextMessage['user_id'];
                final nextUserIsSame = nextUserId == currentUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                    message: ChatMessage['text'],
                    isMe: authenticatinguser.uid == currentUserId,
                  );
                } else {
                  return MessageBubble.first(
                    userImage: ChatMessage['image_url'],
                    username: ChatMessage['user_name'],
                    message: ChatMessage['text'],
                    isMe: authenticatinguser.uid == currentUserId,
                  );
                }
              });
        });
  }
}
