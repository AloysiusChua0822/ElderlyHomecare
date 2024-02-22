import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MaterialApp(
    home: AppointmentScreen(),
  ));
}

Future<List<Map<String, dynamic>>> _fetchDoctors() async {
  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('userType', isEqualTo: 'Health Personnel')
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String name = data['username'] as String? ?? 'Unknown';
    final String specialty = data['specialty'] as String? ?? 'No Specialty';
    final String photoUrl = data['image_url'] as String? ?? 'default_image_url';
    return {
      'name': name,
      'specialty': specialty,
      'image_url': photoUrl,
    };
  }).toList();
}

class AppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchUserType(), // Fetch the user type
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final String userType = snapshot.data ?? '';
          if (userType == 'Health Personnel') {
            // If user type is Health Personnel, show the Health Personnel screen
            return HealthPersonnelScreen();
          } else {
            // If user type is not Health Personnel, show the Appointment screen
            return Scaffold(
              appBar: AppBar(
                title: Text('Appointments'),
                backgroundColor: Colors.teal,
              ),
              body: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchUserAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final List<Map<String, dynamic>> appointments = snapshot.data ?? [];
                    return appointments.isEmpty
                        ? Center(child: Text('No appointments found'))
                        : ListView.builder(
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return _buildAppointmentCard(appointment);
                      },
                    );
                  }
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _showAvailableDoctors(context),
                child: Icon(Icons.add),
                backgroundColor: Colors.teal,
              ),
            );
          }
        }
      },
    );
  }

  Future<String> _fetchUserType() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return snapshot.exists ? (snapshot.data() as Map<String, dynamic>)['userType'] ?? '' : '';
    } else {
      return '';
    }
  }


  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final doctorImageUrl = appointment['doctor_image_url'] ?? '';
    final doctorName = appointment['doctor_name'] ?? '';
    final date = appointment['date'] ?? '';
    final time = appointment['time'] ?? '';
    final additionalDetails = appointment['additional_details'] ?? '';
    final status = appointment['status'] ?? 'pending'; // Default to pending if status is null

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(doctorImageUrl),
          ),
          title: Text(
            doctorName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                'Date: $date',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Time: $time',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Additional Details: $additionalDetails',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Status: $status', // Display the appointment status
                style: TextStyle(fontSize: 14, color: _getStatusColor(status)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    // Define colors for different appointment statuses
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('username', isEqualTo: user.uid) // Change to user.uid if using Firebase Authentication UID
          .get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } else {
      return [];
    }
  }

  void _showAvailableDoctors(BuildContext context) async {
    final List<Map<String, dynamic>> doctors = await _fetchDoctors();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailableDoctorsScreen(doctors: doctors),
      ),
    );
  }
}

class AvailableDoctorsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> doctors;

  AvailableDoctorsScreen({required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find your Doctor'),
        backgroundColor: Colors.white,

        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for doctor',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
              child: Text('Avaliable Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            // Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),

            ),
            // Doctors Grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // to disable GridView's scrolling
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
              ),
              itemCount: doctors.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int index) {
                final doctor = doctors[index];
                return _buildDoctorCard(context, doctor);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: Chip(
        avatar: Icon(icon, color: Colors.white),
        label: Text(label),

        padding: EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doctor) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(doctor: doctor),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CircleAvatar(
                backgroundImage: NetworkImage(doctor['image_url']),
                radius: 50,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    doctor['specialty'],
                    style: TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DoctorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  DoctorDetailScreen({required this.doctor});

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  String selectedDate = '';
  String selectedTime = '';
  String additionalDetails = ''; // Variable to store additional details
  bool appointmentApplied = false; // Variable to track if appointment applied

  List<String> times = [
    '08.00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM'
  ]; // Example times

  DateTime _selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(widget.doctor['image_url']),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                widget.doctor['name'],
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                widget.doctor['specialty'],
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Select Date',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(
                _selectedDateTime.toString().split(' ')[0],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Select Time',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Wrap(
                      spacing: 10,
                      alignment: WrapAlignment.center,
                      children: times.map((time) {
                        return ChoiceChip(
                          label: Text(time),
                          selected: selectedTime == time,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedTime = time;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Additional Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter additional details...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  additionalDetails = value;
                });
              },
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: appointmentApplied
                    ? () {
                  Navigator.pop(context); // Close the screen
                }
                    : (selectedDate.isNotEmpty && selectedTime.isNotEmpty)
                    ? () {
                  // Apply appointment
                  _applyAppointment();
                }
                    : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (pickedDateTime != null) {
      setState(() {
        _selectedDateTime = pickedDateTime;
        selectedDate = _selectedDateTime.toString().split(' ')[0];
      });
    }
  }

  void _applyAppointment() async {
    // Check if user is authenticated
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Create a reference to the appointments collection
      CollectionReference appointments =
      FirebaseFirestore.instance.collection('appointments');

      // Add a new document to the appointments collection
      await appointments.add({
        'username': user.uid, // Use display name of the current user
        'doctor_name': widget.doctor['name'],
        'date': selectedDate,
        'time': selectedTime,
        'additional_details': additionalDetails,
        'status': 'pending', // Default status is pending
        // Add more fields as needed
      });

      // Show confirmation dialog
      _showConfirmationDialog();
    } else {
      // User not authenticated, handle accordingly
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Applied Successfully'),
          content: Text('Your appointment has been successfully applied.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  appointmentApplied = true;
                });
              },
              child: Text('OK'),
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
        title: Text('Appointments'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDoctorAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<Map<String, dynamic>> appointments = snapshot.data ?? [];
            return appointments.isEmpty
                ? Center(child: Text('No appointments found'))
                : ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return _buildAppointmentCard(appointment);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final username = appointment['username'] ?? '';
    final date = appointment['date'] ?? '';
    final time = appointment['time'] ?? '';
    final additionalDetails = appointment['additional_details'] ?? '';
    final status = appointment['status'] ?? 'pending'; // Default to pending if status is null

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          title: Text(
            'User: $username',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                'Date: $date',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Time: $time',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Additional Details: $additionalDetails',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Status: $status', // Display the appointment status
                style: TextStyle(fontSize: 14, color: _getStatusColor(status)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    // Define colors for different appointment statuses
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchDoctorAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doctorName = user.displayName;
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctor_name', isEqualTo: doctorName)
          .get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } else {
      return [];
    }
  }
}
