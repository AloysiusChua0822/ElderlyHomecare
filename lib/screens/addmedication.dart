import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldergit/models/medicationmodel.dart';

class AddMedicationScreen extends StatefulWidget {
  final Medication? medication;

  AddMedicationScreen({this.medication});

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dosageController = TextEditingController();
  TextEditingController _frequencyController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _dosageController.text = widget.medication!.dosage;
      _frequencyController.text = widget.medication!.frequency;
    }
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

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String filePath = 'medications/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final ref = FirebaseStorage.instance.ref().child(filePath);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }

      Map<String, dynamic> medicationData = {
        'name': _nameController.text,
        'dosage': _dosageController.text,
        'frequency': _frequencyController.text,
        'imageUrl': imageUrl ?? '',
      };

      try {
        if (widget.medication == null) {
          await FirebaseFirestore.instance.collection('medications').add(medicationData);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medication added successfully')));
        } else {
          await FirebaseFirestore.instance.collection('medications').doc(widget.medication!.id).update(medicationData);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medication updated successfully')));
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save medication: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_imageFile != null)
                Center(
                  child: Image.file(
                    _imageFile!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Medication Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a medication name' : null,
              ),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'Dosage (e.g., 500mg)'),
                validator: (value) => value!.isEmpty ? 'Please enter the dosage' : null,
              ),
              TextFormField(
                controller: _frequencyController,
                decoration: InputDecoration(labelText: 'Frequency (e.g., daily)'),
                validator: (value) => value!.isEmpty ? 'Please enter the frequency' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.medication == null ? 'Add Medication' : 'Update Medication'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
