import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldergit/model/message.dart';
import 'package:eldergit/widgets/chat_messages.dart';
import 'package:eldergit/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path/path.dart';

class ChatScreen extends StatefulWidget {

  final String receiverUserEmail;
  final String receiverUserID;
  const ChatScreen({super.key,
  required this.receiverUserEmail,
  required this.receiverUserID});

  @override
  State<ChatScreen> createState() => _ChatScreenState();

}
   //get instance of auth and firestore
   class ChatService extends ChangeNotifier{
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    //Send Message
    Future<void> sendMessage(String receiverId, String message) async {
      //get current user info
      final String currentUserId = _firebaseAuth.currentUser!.uid;
      final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
      final Timestamp timestamp = Timestamp.now();
      
      //create a new message
      Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message
      );

      // construct chat room id from current user id and receiver id (sorted to ensure uniqueness)
      List<String> ids = [currentUserId,receiverId]; //sort the ids (this ensures the chat roomid is always same for any)
      ids.sort();
      String chatRoomId = ids.join();

      //add new message to database
      await _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('message')
      .add(newMessage.toMap());
    }
    

    //get messages
    Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
      List<String> ids = [userId,otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");

      return _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .orderBy('timestamp',descending: false)
      .snapshots();
    }
   }

  class _ChatScreenState extends State<ChatScreen>{

    final TextEditingController _messageController = TextEditingController();
    final ChatService _chatService =ChatService();
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    void sendMessage() async {
      if (_messageController.text.isNotEmpty){
        await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
        //clear the text controller after sending the message
        _messageController.clear();
      }
    }

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
        title: Text(widget.receiverUserEmail),
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