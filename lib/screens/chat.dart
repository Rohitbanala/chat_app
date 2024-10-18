import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key,required this.receiverId});
  final receiverId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setUpPushNotifications() async {
    final firebasemessaging = FirebaseMessaging.instance;
    await firebasemessaging.requestPermission();
    final token = await firebasemessaging.getToken();
    firebasemessaging.subscribeToTopic('chat');
    print(token);
  }
  @override
  void initState() {
    setUpPushNotifications();
    super.initState();
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Chat"),
        actions: [
          IconButton(
            onPressed: () {
              
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ChatMessages(receiverId: widget.receiverId,),
            ),
            NewMessages(receiverId: widget.receiverId,),
          ],
        ),
      ),
    );
  }
}
