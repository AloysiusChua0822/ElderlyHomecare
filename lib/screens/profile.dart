import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldergit/widgets/old_image_picker.dart'; // Assuming this is the correct import for the image picker widget

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  String _email = '';
  String _userType = '';
  File? _profilePicUrl;
  bool _passwordVisible = false;
  bool _isUpdated = false; // Flag to track if any updates are made

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _loadUserProfile();
  }

  _loadUserProfile() async {
    if (user != null) {
      var userData = await _firestore.collection('users').doc(user!.uid).get();
      setState(() {
        _usernameController.text = userData.data()?['username'] ?? '';
        _email = userData.data()?['email'] ?? '';
        _userType = userData.data()?['userType'] ?? '';
        _passwordController.text = userData.data()?['password'] ?? '';
        String imagePath = userData.data()?['image_url'] ?? '';
        _profilePicUrl = imagePath.isNotEmpty ? File(imagePath) : null; // Check if imagePath is not empty
      });
    }
  }

  void _updateUserProfile() async {
    if (_isUpdated) {
      try {
        await _firestore.collection('users').doc(user!.uid).update({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'image_url': _profilePicUrl?.path ?? '', // Store the file path or empty string if profile pic is null
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        // Reset the update flag
        setState(() {
          _isUpdated = false;
        });
      } catch (e) {
        print('Error updating profile: $e');
        // Handle error updating profile
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: _isUpdated
            ? [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateUserProfile,
          )
        ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _profilePicUrl != null
                  ? OldImagePicker()
                  : Text('No profile picture available'),
            ),
            SizedBox(height: 20),
            _buildUsernameField(),
            _buildEmailField(),
            _buildPasswordField(),
            _buildUserTypeField(),
            SizedBox(height: 20),
            _buildHealthReportCard(), // Moved the health report card here
          ],
        ),
      ),
    );
  }

  Widget _buildHealthReportCard() {
    return InkWell( // Use InkWell for tap recognition
      onTap: () {
        _navigateToUserListScreen(context); // Navigate to the UserListScreen when tapped
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.favorite, color: Colors.red), // Heart icon
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health report:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right), // Indicating that this can be tapped
          ],
        ),
      ),
    );
  }

  void _navigateToUserListScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UserListScreen(), // The new screen you've created
    ));
  }

  Widget _buildUsernameField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _usernameController,
              readOnly: true,
              onChanged: (value) {},
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _editUsername();
            },
          ),
        ],
      ),
    );
  }

  void _editUsername() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Username'),
        content: TextField(
          controller: _usernameController, // Use the existing username controller.
          decoration: InputDecoration(hintText: 'Enter new username'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog.
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isUpdated = true;
              });
              Navigator.of(context).pop(); // Close the dialog.
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _passwordVisible ? _passwordController : TextEditingController(text: '*' * _passwordController.text.length),
              obscureText: !_passwordVisible,
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Password',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editPassword();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPassword() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Password'),
        content: TextField(
          controller: _passwordController,
          decoration: InputDecoration(hintText: 'Enter new password'),
          obscureText: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password must be at least 6 characters.')),
                );
              } else {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  await user?.updatePassword(_passwordController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password updated successfully!')),
                  );
                  setState(() {
                    _isUpdated = true;
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update password. Please re-authenticate and try again.')),
                  );
                }
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'User Type: $_userType',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Email: $_email',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}






class UserListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('users')
            .where('userType', isNotEqualTo: 'Health Personnel')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }

          List<DocumentSnapshot> users = snapshot.data!.docs;

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              var userData = users[index].data() as Map<String, dynamic>?;
              String imageUrl = userData?['image_url'] as String? ?? ''; // Null check and default value
              String email = userData?['email'] as String? ?? 'No email';
              String username = userData?['username'] as String? ?? 'No name';

              return Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(
                    username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(email),
                  leading: CircleAvatar(
                    backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child: imageUrl.isEmpty ? Icon(Icons.person) : null,
                    radius: 25,
                  ),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: <Widget>[
                      GestureDetector(
                        child: Icon(Icons.info_outline, color: Colors.deepPurple),
                        onTap: () {
                          if (userData != null) {
                            _showUserInfoDialog(context, userData);
                          }
                        },
                      ),
                      Icon(Icons.settings, color: Colors.deepPurple), // Settings icon
                    ],
                  ),
                  onTap: () {
                    if (userData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsScreen(userData: userData),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUserInfoDialog(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Username: ${userData['username'] ?? 'Not available'}'),
            Text('Email: ${userData['email'] ?? 'Not available'}'),
            Text('User Type: ${userData['userType'] ?? 'Not available'}'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      ),
    );
  }
}

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserDetailsScreen({required this.userData});

  @override
  Widget build(BuildContext context) {
    // Extracting user data
    String username = userData['username'] as String? ?? 'No Name';
    String email = userData['email'] as String? ?? 'No Email';
    String imageUrl = userData['image_url'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          CircleAvatar(
            radius: 80,
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            backgroundColor: Colors.grey[200],
            child: imageUrl.isEmpty ? Icon(Icons.person, size: 80) : null,
          ),
          SizedBox(height: 20),
          Text(
            username,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            email,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 30),
          Divider(
            thickness: 2,
            indent: 50,
            endIndent: 50,
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Medication Information',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  userData.containsKey('medications')
                      ? Text(
                    userData['medications'],
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  )
                      : Text(
                    'No medication information available',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class MedicationList extends StatelessWidget {
  final String userId;
  final String currentUserType; // Add currentUserType

  MedicationList({required this.userId, required this.currentUserType});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return StreamBuilder(
      stream: _firestore
          .collection('medications')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No medications found'));
        }

        List<DocumentSnapshot> medications = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: medications.length,
          itemBuilder: (context, index) {
            var medicationData = medications[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: Image.network(medicationData['imageUrl'] ?? '', fit: BoxFit.cover, width: 50, height: 50),
              title: Text(medicationData['medicationName'] ?? 'No Name'),
              subtitle: Text('Dosage: ${medicationData['dosage'] ?? 'No Dosage'}'),
              trailing: Text('Frequency: ${medicationData['frequency'] ?? 'No Frequency'}'),
              onTap: () {
                if (currentUserType == 'Health Personnel') {
                  // Implement edit functionality
                  _editMedication(context, medications[index]);
                }
              },
            );
          },
        );
      },
    );
  }

  void _editMedication(BuildContext context, DocumentSnapshot medicationSnapshot) {
    // Implement edit medication dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Medication'),
        // Add form fields to edit medication details
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add form fields for editing medication details
              // For example:
              TextFormField(
                initialValue: medicationSnapshot['medicationName'],
                decoration: InputDecoration(labelText: 'Medication Name'),
                onChanged: (value) {
                  // Update medication name
                },
              ),
              TextFormField(
                initialValue: medicationSnapshot['dosage'],
                decoration: InputDecoration(labelText: 'Dosage'),
                onChanged: (value) {
                  // Update dosage
                },
              ),
              TextFormField(
                initialValue: medicationSnapshot['frequency'],
                decoration: InputDecoration(labelText: 'Frequency'),
                onChanged: (value) {
                  // Update frequency
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Save changes
              // Implement save functionality
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}