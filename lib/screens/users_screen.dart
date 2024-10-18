import 'package:chat_app/main.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Users extends StatelessWidget {
  const Users({super.key});

  @override
  Widget build(BuildContext context) {
    final autheticatedUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello ${autheticatedUser!.email}"),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, usersnapshot) {
          if (usersnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!usersnapshot.hasData || usersnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No users found"),
            );
          }
          if (usersnapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }
          final loadedusers = usersnapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.only(left: 13, bottom: 40, right: 13),
            itemCount: loadedusers.length,
            itemBuilder: (context, index) => autheticatedUser!.uid ==
                    loadedusers[index].data()['user_id']
                ? Container()
                : ListTile(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(receiverId: loadedusers[index].data()['user_id'],)));
                    },
                    leading: CircleAvatar(
                      foregroundImage:
                          NetworkImage(loadedusers[index].data()['image_url']),
                    ),
                    title: Text(loadedusers[index].data()['user name']),
                    subtitle: Text(loadedusers[index].data()['email']),
                    style: ListTileStyle.list,
                    trailing: const Icon(Icons.message),
                  ),
          );
        },
      ),
    );
  }
}
