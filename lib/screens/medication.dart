import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eldergit/classes/medicationclass.dart';
import 'package:eldergit/screens/addmedication.dart';




class ViewMedicationScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  Stream<List<Medication>> get _medicationsStream {
    final User? user = _auth.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('medications') // Query the 'medications' collection directly
          .where('userId', isEqualTo: user.uid) // Filter by the current user's ID
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => Medication.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
    } else {
      // Return an empty stream if there's no user logged in
      return Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Medications'),
      ),
      body: StreamBuilder<List<Medication>>(
        stream: _medicationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No medications added yet'));
          }
          final medications = snapshot.data!;
          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return ListTile(
                leading: medication.imageUrl != null && medication.imageUrl!.isNotEmpty
                    ? CircleAvatar(backgroundImage: NetworkImage(medication.imageUrl!))
                    : CircleAvatar(child: Icon(Icons.medical_services)),
                title: Text(medication.name),
                subtitle: Text('${medication.dosage}, ${medication.frequency}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => AddMedicationScreen(medication: medication)),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteMedication(context, medication.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddMedicationScreen())),
        child: Icon(Icons.add),
        tooltip: 'Add Medication',
      ),
    );
  }

  Future<void> _deleteMedication(BuildContext context, String medicationId) async {
    // Confirm deletion dialog
    final bool confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Delete'),
        content: Text('Are you sure you want to delete this medication?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('No')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Yes')),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('medications')
            .doc(medicationId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medication deleted successfully')));
      }
    }
  }
}
