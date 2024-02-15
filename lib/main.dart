import 'package:eldergit/provider/firebase_provider.dart';
import 'package:eldergit/screens/mainscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:eldergit/screens/splash.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   runApp(
    ChangeNotifierProvider(
      create: (_) => FirebaseProvider(),
      child: MyApp()),
    );
    
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Care App',
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (snapshot.hasData) {
              return MainScreen();
            }

            return  MainScreen();
          }),
    );
  }
}
