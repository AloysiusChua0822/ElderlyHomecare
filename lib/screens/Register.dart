import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eldergit/screens/Login.dart';
import 'package:eldergit/screens/Home.dart';
import 'package:image_picker/image_picker.dart'; // For directly using ImagePicker if needed
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:eldergit/widgets/user_image_picker.dart'; // Make sure this path matches your project structure

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  File? _userImageFile;
  bool _isLoading = false;

  void _pickImage(File image) {
    setState(() {
      _userImageFile = image;
    });
  }

  Future<void> _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please pick an image.'), backgroundColor: Theme.of(context).errorColor),
      );
      return;
    }

    if (isValid) {
      setState(() {
        _isLoading = true;
      });

      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final ref = FirebaseStorage.instance.ref().child('user_images').child(newUser.user!.uid + '.jpg');

        await ref.putFile(_userImageFile!);
        final imageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(newUser.user!.uid).set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'image_url': imageUrl,
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Theme.of(context).errorColor),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 16);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.deepPurple.shade50],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UserImagePicker(onPickImage: _pickImage),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username', prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                          labelStyle: labelStyle,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a username.';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email', prefixIcon: Icon(Icons.email_rounded),
                          border: OutlineInputBorder(),
                          labelStyle: labelStyle,
                        ),
                        validator: (value) {
                          if (value == null || !value.contains('@')) return 'Please enter a valid email.';
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password', prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                          labelStyle: labelStyle,
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) return 'Password must be at least 6 characters.';
                          return null;
                        },
                      ),
                      SizedBox(height: 40),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _trySubmit,
                        child: Text('Register'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurple,
                          onPrimary: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        child: Text('Have an account? Login', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
