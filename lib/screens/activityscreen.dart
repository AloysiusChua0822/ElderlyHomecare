import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eldergit/models/activitymodel.dart';
import 'package:eldergit/screens/add_activity_screen.dart'; // Assume this is your screen for adding a new activity

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Activity>> _fetchActivities() {
    return _firestore.collection('activities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Activity.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Activities'),
      ),
      body: StreamBuilder<List<Activity>>(
        stream: _fetchActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No activities found'));
          }
          final activities = snapshot.data!;
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: activity.imageUrl.isNotEmpty
                    ? CircleAvatar(backgroundImage: NetworkImage(activity.imageUrl))
                    : CircleAvatar(child: Icon(Icons.photo)),
                title: Text(activity.title),
                subtitle: Text(activity.description),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Assuming AddActivityScreen is the screen where you add new activities
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddActivityScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
