import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldergit/widgets/old_image_picker.dart';


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
      if (!userData.exists) {
        // If user document doesn't exist, create one
        await _firestore.collection('users').doc(user!.uid).set({
          'username': '', // Initialize with empty username
          'email': user!.email,
          // Add other fields as needed
        });
        userData = await _firestore.collection('users').doc(user!.uid).get(); // Retrieve newly created document
      }
      setState(() {
        _usernameController.text = userData.data()?['username'] ?? '';
        _email = userData.data()?['email'] ?? '';
        _userType = userData.data()?['userType'] ?? '';
        _passwordController.text = userData.data()?['password'] ?? '';
        String imagePath = userData.data()?['image_url'] ?? '';
        _profilePicUrl = imagePath.isNotEmpty ? File(imagePath) : null; // Check if imagePath is not empty
      });
      // Check if user is health personnel

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
            ? [IconButton(icon: Icon(Icons.save), onPressed: _updateUserProfile)]
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
            _buildHealthReportCard(context), // Pass context
          ],
        ),
      ),

    );
  }

  Widget _buildHealthReportCard(BuildContext context) { // Accept context parameter
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HealthReportDetailsScreen(healthReportId: 'healthReportId'), // Replace with actual ID
          ),
        );
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


class HealthReportDetailsScreen extends StatelessWidget {
  final String healthReportId;

  HealthReportDetailsScreen({required this.healthReportId});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Health Report Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewMedicalRecordScreen(),
                ),
              );
            },
          ),
          FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('users').doc(user!.uid).get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox();
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return SizedBox();
              }
              final userData = snapshot.data!.data() as Map<String, dynamic>?; // Explicit casting
              final userType = userData?['userType'];

              // Only show the icon if the user type is 'health_personnel'
              if (userType == 'Health Personnel') {
                return IconButton(
                  icon: Icon(Icons.people),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) => HealthPersonnelScreen(),
                        ),
                    );
                  },
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(user!.uid).get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return Text('User data not found');
                }
                Map<String, dynamic> userData =
                snapshot.data!.data() as Map<String, dynamic>;
                String username = userData?['username'] ?? '';
                String imageUrl = userData?['image_url'] ?? '';

                return Column(
                  children: [
                    Center(
                      child: imageUrl.isNotEmpty
                          ? OldImagePicker() // Use OldImagePicker or any other widget to display the user's photo
                          : Text('No profile picture available'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Username: $username',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            _buildMedicationsList(_firestore, user!),
            SizedBox(height: 20),
            _buildMedicalRecordsList(_firestore, user.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsList(FirebaseFirestore firestore, User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('medications')
          .where('userId', isEqualTo: user.uid) // Filter by user ID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No medications found.'));
        }

        List<Medication> medications = snapshot.data!.docs
            .map((doc) =>
            Medication.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: medications.length,
              itemBuilder: (context, index) {
                Medication medication = medications[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      medication.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(medication.name),
                    subtitle: Text(
                        'Dosage: ${medication.dosage}\nFrequency: ${medication.frequency}'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMedicalRecordsList(FirebaseFirestore firestore, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('medical_records')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No medical records found.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> medicalRecordData =
            doc.data() as Map<String, dynamic>;
            String blood = medicalRecordData?['blood'] ?? '';
            String height = medicalRecordData?['height'] ?? '';
            String weight = medicalRecordData?['weight'] ?? '';
            String pressure = medicalRecordData?['pressure'] ?? '';
            String cardiologist =
                medicalRecordData?['cardiologist'] ?? '';

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoBox(Icons.opacity, 'Blood', blood),
                    SizedBox(height: 10),
                    _buildInfoBox(Icons.height, 'Height', height),
                    SizedBox(height: 10),
                    _buildInfoBox(Icons.line_weight, 'Weight', weight),
                    SizedBox(height: 10),
                    _buildInfoBox(Icons.favorite, 'Pressure', pressure),
                    SizedBox(height: 10),
                    _buildInfoBox(
                        Icons.favorite_border, 'Cardiologist', cardiologist),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildInfoBox(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Text(
                value,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String imageUrl;

  Medication(
      {required this.name,
        required this.dosage,
        required this.frequency,
        required this.imageUrl});

  factory Medication.fromFirestore(Map<String, dynamic> firestore) {
    return Medication(
      name: firestore['name'] ?? '',
      dosage: firestore['dosage'] ?? '',
      frequency: firestore['frequency'] ?? '',
      imageUrl: firestore['imageUrl'] ?? '',
    );
  }
}


class NewMedicalRecordScreen extends StatefulWidget {
  @override
  _NewMedicalRecordScreenState createState() => _NewMedicalRecordScreenState();
}

class _NewMedicalRecordScreenState extends State<NewMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloodController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _pressureController = TextEditingController();
  final _cardiologistController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Medical Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _bloodController,
                decoration: InputDecoration(labelText: 'Blood'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter blood information';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(labelText: 'Height'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter height information';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight information';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pressureController,
                decoration: InputDecoration(labelText: 'Pressure'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pressure information';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cardiologistController,
                decoration: InputDecoration(labelText: 'Cardiologist'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardiologist information';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showConfirmationDialog();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to submit the medical record?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitMedicalRecord();
              },
              child: Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  void _submitMedicalRecord() {
    // Add code to submit the medical record to Firestore
    String blood = _bloodController.text;
    String height = _heightController.text;
    String weight = _weightController.text;
    String pressure = _pressureController.text;
    String cardiologist = _cardiologistController.text;

    // Insert into Firestore
    FirebaseFirestore.instance.collection('medical_records').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'blood': blood,
      'height': height,
      'weight': weight,
      'pressure': pressure,
      'cardiologist': cardiologist,
      // Add other fields as needed
    }).then((value) {
      // Handle success
      _showSuccessDialog();
    }).catchError((error) {
      // Handle error
      print('Failed to add medical record: $error');
      // Optionally, show error message to user
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Medical record submitted successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Pop twice to dismiss this screen and return to the previous screen
              },
              child: Text('Okay'),
            ),
          ],
        );
      },
    );
  }
}

class HealthPersonnelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Personnel Screen'),
      ),
      body: HealthReportsList(),
    );
  }
}

class HealthReportsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medical_records').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No health reports found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot report = snapshot.data!.docs[index];
            return HealthReportCard(report: report);
          },
        );
      },
    );
  }
}

class HealthReportCard extends StatelessWidget {
  final DocumentSnapshot report;

  HealthReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    String userId = report['userId'];
    String blood = report['blood'];
    String height = report['height'];
    String weight = report['weight'];
    String pressure = report['pressure'];
    String cardiologist = report['cardiologist'];

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('User not found');
        }

        // Extract username from the user document snapshot
        String username = snapshot.data!['username'];

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username: $username', // Display username instead of userId
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Blood: $blood'),
                Text('Height: $height'),
                Text('Weight: $weight'),
                Text('Pressure: $pressure'),
                Text('Cardiologist: $cardiologist'),
                MedicationsList(userId: userId),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MedicationsList extends StatelessWidget {
  final String userId;

  MedicationsList({required this.userId});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Medications:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('medications')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text('No medications found.');
            }

            return ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: snapshot.data!.docs.map((doc) {
                var medicationData = doc.data() as Map<String, dynamic>;
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: medicationData['imageUrl'] != null
                        ? Image.network(
                      medicationData['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : Icon(Icons.medication, size: 50),
                    title: Text(medicationData['name'] ?? 'No name provided'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dosage: ${medicationData['dosage'] ?? 'No dosage provided'}'),
                        Text('Frequency: ${medicationData['frequency'] ?? 'No frequency provided'}'),
                        // Add more fields as necessary
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}