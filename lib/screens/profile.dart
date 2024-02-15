import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldergit/widgets/user_image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  String _email = '';
  String _userType = '';
  File? _profilePicUrl;
  bool _passwordVisible = false;
  bool _isUpdated = false; // Flag to track if any updates are made

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _loadUserProfile();
  }

  _loadUserProfile() async {
    if (user != null) {
      var userData = await _firestore.collection('users').doc(user!.uid).get();
      setState(() {
        _usernameController.text = userData.data()?['username'] ?? '';
        _email = userData.data()?['email'] ?? '';
        _userType = userData.data()?['userType'] ?? '';
        _passwordController.text = userData.data()?['password'] ?? '';
        _profilePicUrl = File(userData.data()?['image_url'] ?? '');
      });
    }
  }

  void _updateUserProfile() async {
    if (_isUpdated) {
      try {
        await _firestore.collection('users').doc(user!.uid).update({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'image_url': _profilePicUrl?.path, // Store the file path
        });



        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        // Reset the update flag
        setState(() {
          _isUpdated = false;
        });
      } catch (e) {
        print('Error updating profile: $e');
        // Handle error updating profile
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: _isUpdated ? [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateUserProfile,
          )
        ] : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            UserImagePicker(),
            SizedBox(height: 20),
            _buildUsernameField(),
            _buildEmailField(),
            _buildPasswordField(),
            _buildUserTypeField(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _usernameController,
              readOnly: true,
              onChanged: (value) {
              },
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _editUsername();
            },
          ),
        ],
      ),
    );
  }
  void _editUsername() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Username'),
        content: TextField(
          controller: _usernameController, // Use the existing password controller.
          decoration: InputDecoration(hintText: 'Enter new username'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog.
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isUpdated = true;
              });
              Navigator.of(context).pop(); // Close the dialog.
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _passwordVisible ? _passwordController : TextEditingController(text: '*' * _passwordController.text.length),
              obscureText: !_passwordVisible,
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Password',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editPassword();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPassword() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Password'),
        content: TextField(
          controller: _passwordController,
          decoration: InputDecoration(hintText: 'Enter new password'),
          obscureText: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password must be at least 6 characters.')),
                );
              } else {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  await user?.updatePassword(_passwordController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password updated successfully!')),
                  );
                  setState(() {
                    _isUpdated = true;
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update password. Please re-authenticate and try again.')),
                  );
                }
              }
            },
            child: Text('Save'),
          ),

        ],
      ),
    );
  }



  Widget _buildUserTypeField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'User Type: $_userType',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEmailField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Email: $_email',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
