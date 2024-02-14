import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldergit/screens/news.dart';
import '../classes/newsclass.dart'; // Assuming this is your model class

class AddEditNewsScreen extends StatefulWidget {
  final NewsItem? newsItem;

  AddEditNewsScreen({this.newsItem});

  @override
  _AddEditNewsScreenState createState() => _AddEditNewsScreenState();
}

class _AddEditNewsScreenState extends State<AddEditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _imageUrl;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.newsItem?.title ?? '');
    _contentController = TextEditingController(text: widget.newsItem?.content ?? '');
    _imageUrl = widget.newsItem?.imageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    String fileName = 'news/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
    final storageRef = FirebaseStorage.instance.ref().child(fileName);
    await storageRef.putFile(image);
    return await storageRef.getDownloadURL();
  }

  void _saveNews() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    String? imageUrl = _imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    Map<String, dynamic> newsData = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'imageUrl': imageUrl ?? '',
    };

    if (widget.newsItem == null) {
      // Add new news
      await FirebaseFirestore.instance.collection('news').add(newsData);
    } else {
      // Update existing news
      await FirebaseFirestore.instance.collection('news').doc(widget.newsItem!.id).update(newsData);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.newsItem == null ? 'Add News' : 'Edit News'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  validator: (value) => value!.isEmpty ? 'Please enter some content' : null,
                ),
                SizedBox(height: 20),
                if (_imageUrl != null && _imageFile == null)
                  Image.network(_imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
                if (_imageFile != null)
                  Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text('Pick Image'),
                  onPressed: _pickImage,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveNews,
                  child: Text('Save News'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
