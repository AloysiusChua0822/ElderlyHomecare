import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as Path;

class AddActivityScreen extends StatefulWidget {
  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 400,
    );
    if (pickedImageFile != null) {
      setState(() {
        _image = File(pickedImageFile.path);
      });
    }
  }

  Future<void> _uploadActivity() async {
    if (!_formKey.currentState!.validate() || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and pick an image.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      // Upload image to Firebase Storage
      String fileName = Path.basename(_image!.path);
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('activity_images/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Add activity to Firestore
      await FirebaseFirestore.instance.collection('activities').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': imageUrl,
      });

      Navigator.of(context).pop(); // Return to the previous screen after successful upload
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Activity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  return value!.isEmpty ? 'Please enter a title' : null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  return value!.isEmpty ? 'Please enter a description' : null;
                },
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: _image != null
                    ? Image.file(
                  _image!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: Icon(Icons.image, size: 50),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _uploadActivity,
                child: Text('Add Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
