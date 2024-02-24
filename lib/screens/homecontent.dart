import 'package:flutter/material.dart';
import 'package:eldergit/screens/activityscreen.dart';
import 'package:eldergit/screens/medication.dart';
import 'package:eldergit/screens/news.dart';
import 'package:eldergit/screens/Appointments.dart';
import 'package:eldergit/ShoppingCart/ShoppingCart_Intro.dart';

// Add any other necessary imports here

class BigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color cardColor;
  final VoidCallback onTap;
  final double width;
  final double height;

  const BigButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.cardColor,
    required this.onTap,
    this.width = 120, // Default width
    this.height = 150, // Default height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: iconColor),
              SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      margin: EdgeInsets.all(8),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String username;
  final String profilePicUrl;

  HomeContent({required this.username, required this.profilePicUrl});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/home-background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          SizedBox(height: MediaQuery.of(context).padding.top),
          if (widget.profilePicUrl.isNotEmpty)
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(widget.profilePicUrl),
              backgroundColor: Colors.transparent,
            ),
          Text(
            'Hi, ${widget.username}!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, shadows: [Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black.withOpacity(0.5))]),
          ),
          SizedBox(height: 350),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: <Widget>[
                BigButton(
                  icon: Icons.accessibility_new,
                  label: 'Activity',
                  iconColor: Colors.white,
                  cardColor: Colors.lightBlue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityScreen())),
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                BigButton(
                  icon: Icons.healing,
                  label: 'Medication',
                  iconColor: Colors.white,
                  cardColor: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMedicationScreen())),
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                BigButton(
                  icon: Icons.article,
                  label: 'News',
                  iconColor: Colors.white,
                  cardColor: Colors.orangeAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewNewsScreen())),
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                BigButton(
                  icon: Icons.event,
                  label: 'Appointments',
                  iconColor: Colors.white,
                  cardColor: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentScreen())),
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                BigButton(
                  icon: Icons.shopify_outlined,
                  label: 'Shop',
                  iconColor: Colors.white,
                  cardColor: Colors.redAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShopIntroPage())),
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) { // Adjust the count to match your number of pages
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _currentPage == index ? 20 : 8,
                height: 8,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.blue : Colors.grey,
                ),
              );
            }),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}