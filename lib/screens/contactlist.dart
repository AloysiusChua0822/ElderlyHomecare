import 'dart:ffi';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart'; 
import 'package:eldergit/widgets/chat_messages.dart';
import 'package:eldergit/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';



class FirebaseService {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference().child('contacts');

  Stream<List<Contact>> getContactList() {
    return _databaseReference.onValue.map((event) {
      final Map<dynamic, dynamic>? contactsMap =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (contactsMap == null) return <Contact>[];

      return contactsMap.entries.map((entry) {
        final Map<dynamic, dynamic> contactData = entry.value;
        return Contact(contactData['name'], contactData['phone']);
      }).toList();
    });
  }
}

class Contact {
  final String name;
  final String phone;

  Contact(this.name, this.phone);
}

class ContactListScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService(); // Instantiate FirebaseService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact List'),
      ),
      body: StreamBuilder<List<Contact>>(
        stream: _firebaseService.getContactList(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final contact = snapshot.data![index];
                return ListTile(
                  title: Text(contact.name),
                  subtitle: Text(contact.phone),
                );
              },
            );
          } else {
            return Center(
              child: Text('No contacts available'),
            );
          }
        },
      ),
    );
  }
}

