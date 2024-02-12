import 'package:flutter/material.dart';
import 'Login.dart';
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    // Define your theme colors and styles
    Color textColor2 = Colors.white;
    Color textColor = Colors.black;
    TextStyle labelStyle = TextStyle(color: textColor.withOpacity(0.7), fontSize: 16);
    TextStyle buttonTextStyle = TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.deepPurple.shade50],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Register', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                    SizedBox(height: 40),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Username', prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: labelStyle,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: textColor.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: textColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email', prefixIcon: Icon(Icons.email_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: labelStyle,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: textColor.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: textColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password', prefixIcon: Icon(Icons.password_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: labelStyle,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: textColor.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: textColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Register', style: TextStyle(color: textColor2)),
                      style: ElevatedButton.styleFrom(
                        primary: textColor,
                        minimumSize: Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text('Have an account? Login',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
