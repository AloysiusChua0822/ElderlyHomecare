import 'package:flutter/material.dart';
import 'package:eldergit/screens/activityscreen.dart';
import 'package:eldergit/screens/medication.dart';
import 'package:eldergit/screens/news.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import other necessary screens and widgets here

class BigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color cardColor;
  final VoidCallback onTap;
  final double width;

  const BigButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.cardColor,
    required this.onTap,
    this.width = 155,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Here we use AspectRatio to maintain the button's aspect ratio
    return Container(
      width: width,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8),
        color: cardColor,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: iconColor),
                SizedBox(height: 10),
                Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
      ),
    );
  }
}

// This is your HomeContent widget.
class HomeContent extends StatelessWidget {
  final String username;
  final String profilePicUrl;

  HomeContent({required this.username, required this.profilePicUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/home-background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              if (profilePicUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(profilePicUrl),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Hi, $username!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.grey.withOpacity(0.5))],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  children: <Widget>[
                    BigButton(
                      icon: Icons.accessibility_new,
                      label: 'Activity',
                      iconColor: Colors.white,
                      cardColor: Colors.lightBlue,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityScreen()));
                      },
                    ),
                    BigButton(
                      icon: Icons.healing,
                      label: 'Medication',
                      iconColor: Colors.white,
                      cardColor: Colors.green,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMedicationScreen()));
                      },
                    ),
                    BigButton(
                      icon: Icons.article,
                      label: 'News',
                      iconColor: Colors.white,
                      cardColor: Colors.orangeAccent,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewNewsScreen()));
                      },
                    ),
                    BigButton(
                      icon: Icons.event,
                      label: 'Appointments',
                      iconColor: Colors.white,
                      cardColor: Colors.purple,
                      onTap: () {
//Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentScreen())); // Ensure you have an AppointmentScreen
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
