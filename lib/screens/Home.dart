import 'package:eldergit/screens/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:eldergit/screens/activityscreen.dart';
import 'package:eldergit/screens/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _username = userData.data()?['username'] ?? 'User';
        _profilePicUrl = userData.data()?['image_url'] ?? 'User'; // Fetch profile picture URL
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getTabContent() {
    switch (_selectedIndex) {
      case 1: return Text('Community Content');
      case 2: return Text('Messages Content');
      case 3: return Text('Profile Content');
      default: return Text('');
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen())); // Assuming LoginScreen is your login screen.
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
            // Background image
            Positioned.fill(
              child: Opacity(
                opacity: 1, // Adjust the background image opacity
                child: Image.asset(
                  'assets/home-background.jpg', // Path to your background image
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
                  height: 130, // Adjust the height as needed
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    children: <Widget>[
                      _bigButton(context, Icons.accessibility_new, 'Activity', Colors.white, Colors.lightBlue, () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityScreen()));
                      }),
                      _bigButton(context, Icons.healing, 'Medication', Colors.white, Colors.green, () {
                        // Navigate to Medication Screen or perform action
                      }),
                      _bigButton(context, Icons.article, 'News', Colors.white, Colors.orangeAccent, () {
                        // Navigate to News Screen or perform action
                      }),
                    ],
                  ),
                )

              ],
            ),
          ],
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.blue), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group, color: Colors.grey), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.message, color: Colors.grey), label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.person, color: Colors.grey), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _bigButton(BuildContext context, IconData icon, String label, Color iconColor, Color cardColor, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8),
      color: cardColor, // Set the background color of the card here
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 155, // Adjust the width as needed
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
