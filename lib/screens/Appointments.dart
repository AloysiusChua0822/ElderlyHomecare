import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        // Your existing ListView content
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAvailableDoctors(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
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

  List<String> times = [
    '08.00 AM',
    '09:00 AM',
    '10:00 AM',
    '11.00 AM',
    '2.00 PM',
    '3:00 PM'
  ]; // Example times

  DateTime _selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.doctor['image_url']),
            ),
            Text(
              widget.doctor['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.doctor['specialty'],
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Divider(),
            ListTile(
              title: Text(
                _selectedDateTime.toString().split(' ')[0],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 20),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Wrap(
                    spacing: 8.0,
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectedDate.isNotEmpty && selectedTime.isNotEmpty
                        ? () {
                      // TODO: Implement booking logic
                    }
                        : null,
                    child: Text('Book an Appointment'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
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
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (pickedDateTime != null) {
      setState(() {
        _selectedDateTime = pickedDateTime;
        selectedDate = _selectedDateTime.toString().split(' ')[0];
      });
    }
  }
}