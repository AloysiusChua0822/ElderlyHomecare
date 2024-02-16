import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OldImagePicker extends StatefulWidget {
  const OldImagePicker({Key? key}) : super(key: key);

  @override
  _OldImagePickerState createState() => _OldImagePickerState();
}

class _OldImagePickerState extends State<OldImagePicker> {
  File? _pickedImageFile;
  String? _userImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
  }

  Future<void> _loadUserProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _userImageUrl = userData.data()?['image_url'] as String?;
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

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${user.uid}.jpg');

    await ref.putFile(_pickedImageFile!);

    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users')
        .doc(user.uid)
        .set({
      'image_url': url,
    }, SetOptions(merge: true));

    setState(() {
      _userImageUrl = url;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: _userImageUrl != null ? NetworkImage(_userImageUrl!) : _pickedImageFile != null ? FileImage(_pickedImageFile!) : const AssetImage('assets/placeholder-avatar.png') as ImageProvider,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Change Image'),
        ),
      ],
    );
  }
}