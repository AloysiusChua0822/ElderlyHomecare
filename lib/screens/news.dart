import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eldergit/classes/newsclass.dart'; // Import your NewsItem model
import 'package:eldergit/screens/addnews.dart'; // Import your AddNewsScreen

class ViewNewsScreen extends StatefulWidget {
  @override
  _ViewNewsScreenState createState() => _ViewNewsScreenState();
}

class _ViewNewsScreenState extends State<ViewNewsScreen> {
  final Stream<List<NewsItem>> _newsStream = FirebaseFirestore.instance
      .collection('news')
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => NewsItem.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
      .toList());

  bool _isCharityWorker = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    // Assuming you have a field in your users collection that marks charity workers
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final isCharityWorker = userData.data()?['userType'] == "Charity Worker";
      setState(() {
        _isCharityWorker = isCharityWorker;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View News'),
      ),
      body: StreamBuilder<List<NewsItem>>(
        stream: _newsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No news available'));
          }
          final newsItems = snapshot.data!;
          return ListView.builder(
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              final item = newsItems[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text(item.content),
                onTap: () {
                  // Navigate to detail screen if needed
                },
              );
            },
          );
        },
      ),
      floatingActionButton: _isCharityWorker ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditNewsScreen()));
        },
        child: Icon(Icons.add),
      ) : null,
    );
  }
}
