import 'package:eldergit/ShoppingCart/ShoppingCart_Intro.dart';
import 'package:eldergit/ShoppingCart/shopping_list.dart';
import 'package:eldergit/ShoppingCart/Cart_Page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: Icon(
                    Icons.shopping_bag,
                    size: 72,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Shop tile
              ShoppingListTile(
                text: "Shop",
                icon: Icons.home,
                onTap: () => Navigator.pop(context),
              ),

              // Cart tile
              ShoppingListTile(
                text: "Cart",
                icon: Icons.shopping_cart,
                onTap: () {
                  // Pop drawer first
                  Navigator.pop(context);

                  // Go to cart page
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CartPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: ShoppingListTile(
              text: "Exit",
              onTap: () {
                Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ShopIntroPage(),
                ),
              );},
              icon: Icons.logout,
            ),
          ),
        ],
      ),
    );
  }
}
