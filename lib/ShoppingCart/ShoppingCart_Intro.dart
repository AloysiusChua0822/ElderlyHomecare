import 'package:flutter/material.dart';
import 'package:eldergit/ShoppingCart/ShopPage.dart';
import 'package:eldergit/ShoppingCart/StartButton.dart';

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
                    builder: (context) => ShopPage(),
                  ),
                );
              },
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}
