import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  String _userType = '';
  String _profilePicUrl = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserProfile();
  }

  _loadUserProfile() async {
    if (user != null) {
      var userData = await _firestore.collection('users').doc(user!.uid).get();
      _usernameController.text = userData.data()?['username'] ?? '';
      _emailController.text = user!.email ?? '';
      _userType = userData.data()?['userType'] ?? '';
      _profilePicUrl = userData.data()?['image_url'] ?? ''; // Fetch profile picture URL from Firestore
      setState(() {}); // This will trigger a rebuild with the updated information
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Display the profile image
          CircleAvatar(
            radius: 60,
            backgroundImage: _profilePicUrl.isNotEmpty ? NetworkImage(_profilePicUrl) : AssetImage('path/to/default/image') as ImageProvider,
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 20),
          // Display username
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
            readOnly: true,
          ),
          SizedBox(height: 10),
          // Display email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            readOnly: true,
          ),
          SizedBox(height: 10),
          // Display user type in a non-clickable way
          ListTile(
            title: Text('User Type'),
            subtitle: Text(_userType, style: TextStyle(color: Colors.grey[500])),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Logic for updating profile (except user type)
            },
            child: Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}
