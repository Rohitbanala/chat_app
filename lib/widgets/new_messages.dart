import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key,required this.receiverId});
  final receiverId;
  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  var _messageController = TextEditingController();
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    _messageController.clear();
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser!;
    final userdata = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final chatId = user.uid.compareTo(widget.receiverId) < 0 ? '${user.uid}_${widget.receiverId}' : '${widget.receiverId}_${user.uid}';
    final messageId = Timestamp.now().millisecondsSinceEpoch.toString();
    FirebaseFirestore.instance.collection('chat').doc(chatId).collection('messages').doc(messageId).set({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'user_id': user.uid,
      'user_name': userdata.data()!['user name'],
      'image_url': userdata.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: const InputDecoration(label: Text("Send a message...")),
          )),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: submitMessage,
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
