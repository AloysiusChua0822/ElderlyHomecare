import 'package:eldergit/ShoppingCart/product.dart';
import 'package:flutter/cupertino.dart';

class Shop extends ChangeNotifier{
  final List<Product> _shop = [
    Product(
        name: "Product: 10pcs/Bag Adult Diaper Pull-ups Pants Disposable Diapers Care Adult Diapers for Senior Women Elderly Men Pregnant Women",
        price: "RM 10.99",
        description: "Click ME!"
    ),

    Product(
        name: "Product: Elderly Turning Over Aid, Bed Support for Elderly, Care Products Elderly bed turn over",
        price: "RM 44.00",
        description:"Click ME!",
    ),

    Product(
        name: "Product: GT MEDIT GERMANY Adjustable Height Medical Foldable Flexible Cane Walker Crutch Aid Mobility Stick / Tongkat",
        price: "RM 10.65",
        description:"Click ME!"
    ),

    Product(
        name: "Product: Elderly people's urinary incontinence underwear, adult urine leakage diaper pad, anti-leakage bedwetting artifact, toilet supplies, diaper pants",
        price: "RM 10.99",
        description:"Click ME!"
    ),
  ];

  //user cart
  List<Product> _cart = [];

  //get product list
List<Product>get shop => _shop;

//get user cart
List<Product> get cart => _cart;
}