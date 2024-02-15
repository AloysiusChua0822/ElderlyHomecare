import 'dart:ffi';
import 'dart:typed_data';
import 'package:eldergit/model/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; 
import 'package:eldergit/widgets/chat_messages.dart';
import 'package:eldergit/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:eldergit/widgets/user_item.dart';
import 'package:eldergit/provider/firebase_provider.dart';
import 'package:provider/provider.dart';

class ChatsScreen extends StatefulWidget{
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatsScreen>{
  @override
  void initState(){
    Provider.of<FirebaseProvider>(context,listen:false)
    .getAllUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chats'),
    ),
    body: Consumer<FirebaseProvider>(
      builder:(context,value,child){
        return ListView.separated(
          padding: 
          const EdgeInsets.symmetric(horizontal: 16),
          itemCount: value.users.length,
          separatorBuilder: ((context, index) => 
          const SizedBox(height: 18,)),
          itemBuilder: (context,index)=>
          UserItem(user: value.users[index]),
    );
      }
    )

  );
}