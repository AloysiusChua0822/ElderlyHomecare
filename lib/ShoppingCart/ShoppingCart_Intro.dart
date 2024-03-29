import 'package:flutter/material.dart';
import 'package:eldergit/ShoppingCart/Shop.dart';
import 'package:eldergit/ShoppingCart/ShopPage.dart';
import 'package:eldergit/ShoppingCart/StartButton.dart';
import 'package:eldergit/screens/Home.dart';

class ShopIntroPage extends StatelessWidget {
  const ShopIntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag,
              size: 72,
              color: Colors.greenAccent,
            ),

            const SizedBox(height: 25),
            // title
            Text(
              "Shop",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 10),
            // sub title
            Text(
              "Premium Quality Products",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 25),
            // button
            StartButton(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ShopPage(shop: Shop()), // Pass an instance of the Shop class
                  ),
                );
              },
              child: Icon(Icons.arrow_forward), // Removed unnecessary const
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>  HomeScreen(), // Pass an instance of the Shop class
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
