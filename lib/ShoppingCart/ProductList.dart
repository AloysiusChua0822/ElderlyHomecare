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
      child: Column(
        children: [
          //product favorite
          Icon(Icons.favorite),

      //product name
      Text(product.name),

      //product description
      Text(product.description),

      //product price
      Text(product.price.toStringAsFixed(2)),
        ],
      ),
    );

  }
}