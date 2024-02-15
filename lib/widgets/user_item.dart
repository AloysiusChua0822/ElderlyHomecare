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
      CircleAvatar(
        backgroundColor: widget.user.isOnline
        ?Colors.green
        :Colors.grey,
        radius: 5,
      ),
    ],
  ),
  title: Text(
    widget.user.name,
    style: const TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  subtitle: Text(
    'Last Active: ${timeago.format(widget.user.lastActive)}',
    maxLines: 2,
    style: const TextStyle(
      color: Colors.black,
      fontSize: 15,
      overflow: TextOverflow.ellipsis,
    ),
  ),
);
}