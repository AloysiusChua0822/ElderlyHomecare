import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eldergit/screens/chat.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Chats'),
      actions: [
        IconButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(
            Icons.logout,
            color: Colors.black,
          ),
        ),
      ],
    ),
    body: _buildUserList(),
  );

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildUserListItem(data);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> data) {
    return ListTile(
      title: Text(data['username']),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiverUserEmail: data['email'],
              receiverUserID: data['username'],
            ),
          ),
        );
      },
    );
  }
}
