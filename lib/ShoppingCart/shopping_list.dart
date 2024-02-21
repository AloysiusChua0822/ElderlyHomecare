import 'package:flutter/material.dart';

class ShoppingListTile extends StatelessWidget{
  final String text;
  final IconData icon;
  final void Function()? onTap;

  const ShoppingListTile({
    super.key,
    required this.text,
  required this.onTap, required this.icon,});

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.grey,
      ),
      title:  Text(text),
      onTap: onTap,
    ),
    );
  }
}