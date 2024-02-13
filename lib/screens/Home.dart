import 'package:eldergit/screens/activityscreen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // The index of the currently selected tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add your navigation logic here. For example:
    switch (index) {
      case 0:
      // Navigate to Home
      // Navigator.of(context).pushNamed('/home');
        break;
      case 1:
      // Navigate to Community
      // Navigator.of(context).pushNamed('/community');
        break;
      case 2:
      // Navigate to Messages
      // Navigator.of(context).pushNamed('/messages');
        break;
      case 3:
      // Navigate to Profile
      // Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  // Define the UI for each tab. For now, we will just show a placeholder Text widget.
  Widget _getTabContent() {
    switch (_selectedIndex) {
      case 0: // Home
        return Text('Home Content'); // Replace with actual home content
      case 1: // Community
        return Text('Community Content'); // Replace with actual community content
      case 2: // Messages
        return Text('Messages Content'); // Replace with actual messages content
      case 3: // Profile
        return Text('Profile Content'); // Replace with actual profile content
      default:
        return Text('Other Content'); // Fallback content
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/background-2.jpg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, Alex!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16, // Adjust as needed
                    right: 16,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/old-avatar.png'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: 5, // Adjust the number of items as needed
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal[700],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.medical_services, size: 50, color: Colors.white),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Atenolol', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text('1 pill/day', style: TextStyle(fontSize: 14, color: Colors.white)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Icon(Icons.access_time_filled, color: Colors.white),
                            Text('10 am', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        SizedBox(width: 16),
                        Icon(Icons.add_circle_outline, size: 48, color: Colors.white),
                        SizedBox(width: 8),
                        Icon(Icons.remove_circle_outline, size: 48, color: Colors.white),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: Colors.grey),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, color: Colors.grey),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActivityScreen()),
          );
        }, // This closing parenthesis ends the onPressed function
        child: Icon(Icons.add),
        tooltip: 'Add Activity', // Optional, provides a label for accessibility
      ),
// Optional: Position your button if you don't want it in the default location
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}