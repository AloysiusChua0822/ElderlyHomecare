import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldergit/classes/activityclass.dart';
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

  Future<void> _joinActivity(String activityId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('activities').doc(activityId).update({
        'participants': FieldValue.arrayUnion([user.uid])
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You have joined the activity')));
    }
  }

  void _viewParticipants(BuildContext context, List<String> participants) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Participants"),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: participants.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(participants[index]).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }
                  // Correctly cast the snapshot data to Map<String, dynamic> before accessing it
                  final data = snapshot.data?.data() as Map<String, dynamic>?;
                  String participantName = data?['username'] ?? 'Unknown';
                  return ListTile(title: Text(participantName));
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Join button
                    IconButton(
                      icon: Icon(Icons.group_add),
                      onPressed: () async {
                        await _joinActivity(activity.id);
                      },
                    ),
                    // View participants button
                    IconButton(
                      icon: Icon(Icons.people),
                      onPressed: () {
                        _viewParticipants(context, activity.participants);
                      },
                    ),
                  ],
                ),
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
