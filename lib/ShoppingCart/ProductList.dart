import 'package:flutter/material.dart';
import 'package:eldergit/ShoppingCart/product.dart';

class ProductList extends StatelessWidget{
  final Product product;

  const ProductList ({
  super.key,
  required this.product,
});

  @override
Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
          color: Colors.lightGreenAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          //product favorite
          Icon(Icons.favorite),

      //product name
      Text(product.name),

      //product description
      Text(product.description),

      //product price
      Text(product.price),
        ],
      ),
    );

  }
}