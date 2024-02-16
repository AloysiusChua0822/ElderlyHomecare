import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewImagePicker extends StatefulWidget {
  final Function(File pickedImage) onImagePicked;

  const NewImagePicker({Key? key, required this.onImagePicked}) : super(key: key);

  @override
  _NewImagePickerState createState() => _NewImagePickerState();
}

class _NewImagePickerState extends State<NewImagePicker> {
  File? _selectedImageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      setState(() {
        _selectedImageFile = imageFile;
      });
      widget.onImagePicked(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: _selectedImageFile != null
              ? FileImage(_selectedImageFile!) as ImageProvider<Object>
              : const AssetImage('assets/old-avatar.png') as ImageProvider<Object>,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Upload Image'),
        ),
      ],
    );
  }
}
