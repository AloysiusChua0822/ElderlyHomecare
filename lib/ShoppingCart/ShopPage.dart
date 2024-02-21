import 'package:eldergit/ShoppingCart/my_drawer.dart';
import 'package:flutter/material.dart';

class ShopPage extends StatelessWidget{
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:Colors.black,
        title: const Text("Shop Page"),
      ),
      drawer: const MyDrawer(),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemBuilder: (context,index){
          //get each individual product from shop
        }
      ),
    );
  }
}