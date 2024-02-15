import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({Key? key}) : super(key: key);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
  String? _userImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
  }

  Future<void> _loadUserProfileImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, fetch their profile image URL
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _userImageUrl = userData.data()?['image_url'] as String?;
      });
    } else {
      // User not logged in, show placeholder
      setState(() {
        _userImageUrl = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Upload image to Firebase Storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(user.uid + '.jpg');

        await ref.putFile(imageFile);

        // Get the URL of the uploaded image
        final url = await ref.getDownloadURL();

        // Update Firestore user document with new image URL
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'image_url': url,
        });

        setState(() {
          _userImageUrl = url;
        });
      } else {
        // If there's no logged in user, just update the local state to show the picked image
        setState(() {
          _pickedImageFile = File('assets/old-avatar.png');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: _userImageUrl != null
              ? NetworkImage(_userImageUrl!)
              : _pickedImageFile != null
              ? FileImage(_pickedImageFile!)
              : AssetImage('assets/old-avatar.png') as ImageProvider,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            'Upload Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
