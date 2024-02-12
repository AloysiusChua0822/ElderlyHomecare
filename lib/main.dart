import 'Login.dart';
import 'Register.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Care App',
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Logo at the top
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.jpg',
                      fit: BoxFit.cover,
                      width: 100.0,
                      height: 100.0,
                    ),
                  ),
                ),
              ),
            ),
            // Buttons at the bottom using Builder to get the correct context
            Builder(
              builder: (BuildContext innerContext) {
                return Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: <Widget>[
                      ElevatedButton.icon(
                        icon: Icon(Icons.person_2_rounded),
                        label: Text('Sign up'),
                        onPressed: () {
                          Navigator.push(
                            innerContext,
                            MaterialPageRoute(builder: (context) => RegisterScreen()),
                          );                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                      SizedBox(height: 10), // For spacing
                      // Login button
                      ElevatedButton(
                        child: Text('Login'),
                        onPressed: () {
                          // Use innerContext to push the new route
                          Navigator.push(
                            innerContext,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.teal,
                          onPrimary: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
