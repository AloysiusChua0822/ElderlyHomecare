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
        title: Text('Available Doctors'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 100.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryItem('Dental', Icons.face),
                _buildCategoryItem('Heart', Icons.favorite_border),
                _buildCategoryItem('Eyes', Icons.visibility),
                // Add more categories here
              ],
            ),
          ),
          Divider(),
          // Recommended Doctors Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended Doctors',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
          // Doctors List
          Expanded(
            child: ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (BuildContext context, int index) {
                final doctor = doctors[index];
                return _buildDoctorCard(doctor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    return Container(
      width: 120.0,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48.0, color: Colors.blueAccent),
          SizedBox(height: 8.0),
          Text(
            title,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30.0,
          backgroundImage: NetworkImage(doctor['image_url']),
        ),
        title: Text(doctor['name']),
        subtitle: Text(doctor['specialty']),
        trailing: IconButton(
          icon: Icon(Icons.favorite_border),
          onPressed: () {},
        ),
      ),
    );
  }
}