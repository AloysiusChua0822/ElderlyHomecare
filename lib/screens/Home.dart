import 'package:eldergit/screens/Appointments.dart';
import 'package:eldergit/screens/addmedication.dart';
import 'package:eldergit/screens/chat.dart';
import 'package:eldergit/screens/mainscreen.dart';
import 'package:eldergit/screens/medication.dart';
import 'package:eldergit/screens/news.dart';
import 'package:flutter/material.dart';
import 'package:eldergit/screens/activityscreen.dart';
import 'package:eldergit/screens/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eldergit/screens/Community.dart';
import 'package:eldergit/screens/Appointments.dart'; // Import the Appointments screen
import 'package:eldergit/screens/chats_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _username = 'User';
  String _profilePicUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _username = userData.data()?['username'] ?? 'User';
        _profilePicUrl = userData.data()?['image_url'] ?? 'User'; // Fetch profile picture URL
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => CommunityListScreen(),
      ));
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ChatsScreen(),
      ));
    } else if (index == 4) { // Add condition for index 4 (Appointments)
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => AppointmentScreen(), // Replace AppointmentsScreen with the actual class name of your Appointments screen
      ));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _getTabContent() {
    switch (_selectedIndex) {
      case 1:
        return CommunityListScreen();
      case 2:
        return ChatsScreen();
      case 3:
        return Text('Profile Content');
      default:
        return SizedBox.shrink();
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 1,
                  child: Image.asset(
                    'assets/home-background.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  if (_profilePicUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(_profilePicUrl),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hi, $_username!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: _getTabContent(),
                  ),
                  SizedBox(
                    height: 130,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      children: <Widget>[
                        _bigButton(context, Icons.accessibility_new, 'Activity',
                            Colors.white, Colors.lightBlue, () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => ActivityScreen()));
                            }),
                        _bigButton(context, Icons.healing, 'Medication',
                            Colors.white, Colors.green, () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => ViewMedicationScreen()));
                            }),
                        _bigButton(context, Icons.article, 'News', Colors.white,
                            Colors.orangeAccent, () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => ViewNewsScreen()));
                            }),
                        _bigButton(context, Icons.event, 'Appointments',
                            Colors.white, Colors.purple, () { // Add button for Appointments
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => AppointmentScreen()));
                            }),
                      ],
                    ),
                  )
                ],
              ),
            ],
          )),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.blue), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group, color: Colors.grey), label: 'Community'),
          BottomNavigationBarItem(
              icon: Icon(Icons.message, color: Colors.grey), label: 'Message'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.grey), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _bigButton(BuildContext context, IconData icon, String label,
      Color iconColor, Color cardColor, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 155,
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: iconColor),
              SizedBox(height: 10),
              Text(label, style: TextStyle(fontSize: 20, color: Colors.white)),
            ],
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
    );
  }
}
