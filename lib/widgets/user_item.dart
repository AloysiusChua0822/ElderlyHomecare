import 'package:eldergit/model/user.dart';
import 'package:flutter/material.dart';
import 'package:eldergit/screens/chats_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserItem extends StatefulWidget{
  const UserItem({super.key,required this.user});

  final UserModel user;

  @override
  State<UserItem> createState () => _UserItemState();
}

class _UserItemState extends State<UserItem>{
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading:  Stack(
      alignment: Alignment.bottomRight,
      children: [CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(widget.user.image),
      ),
<<<<<<< HEAD
      CircleAvatar(
      ),
=======
>>>>>>> d83ab7d50c7be6d099b1d2e48956f777aa0ba202
    ],
  ),
  title: Text(
    widget.user.username,
    style: const TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
);
}