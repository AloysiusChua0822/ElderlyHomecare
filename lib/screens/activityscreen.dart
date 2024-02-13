import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldergit/models/activitymodel.dart';
import 'package:eldergit/screens/add_activity_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Activity>> _fetchActivities() {
    return _firestore.collection('activities').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Activity.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<String> _fetchCurrentUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return ""; // No user logged in
    final userData = await _firestore.collection('users').doc(user.uid).get();
    return userData.data()?['userType'] ?? ""; // Assuming 'userType' is the field name
  }

  Future<void> _showDeleteActivityDialog() async {
    final userType = await _fetchCurrentUserType();
    if (userType != "Charity Worker") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only Allowed Users can use this function.")),
      );
      return;
    }

    final activitiesSnapshot = await _firestore.collection('activities').get();
    final activities = activitiesSnapshot.docs
        .map((doc) => Activity.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    if (activities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No activities available to delete.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Activity"),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(activities[index].title),
                onTap: () async {
                  Navigator.of(context).pop(); // Close the current dialog
                  _confirmDeleteActivity(activities[index].id, activities[index].title); // Confirm before deleting
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteActivity(String activityId, String activityTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete \"$activityTitle\"?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the confirmation dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await _firestore.collection('activities').doc(activityId).delete();
              Navigator.of(context).pop(); // Dismiss the confirmation dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("\"$activityTitle\" deleted successfully.")),
              );
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final userType = await _fetchCurrentUserType();
              if (userType == "Charity Worker") {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddActivityScreen()));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Only Allowed Users can use this function.")),
                );
              }
            },
            child: Icon(Icons.add),
            heroTag: "addActivity",
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _showDeleteActivityDialog,
            child: Icon(Icons.delete),
            heroTag: "deleteActivity",
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
