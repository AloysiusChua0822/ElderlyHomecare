import 'package:eldergit/widgets/chat_messages.dart';
import 'package:eldergit/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();

}

  class _ChatScreenState extends State<ChatScreen>{
    void setupPushNotifications() async{
      final fcm = FirebaseMessaging.instance;

      await fcm.requestPermission();
      final token = await fcm.getToken();
      print(token);
    }
  

@override
void initState(){
  super.initState();
  setupPushNotifications();
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterChat'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: const [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
  }