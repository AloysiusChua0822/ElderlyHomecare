import 'package:flutter/material.dart';

class StartButton extends StatelessWidget{
  final void Function()? onTap;
  final Widget child;

  const StartButton({super.key,required this.onTap,required this.child});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
        padding: const EdgeInsets.all(25),
        child: child,
      ),
    );
  }
}