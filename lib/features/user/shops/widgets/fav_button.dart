import 'package:flutter/material.dart';

class FavButton extends StatelessWidget {
  const FavButton({required this.isActive, required this.onTap});
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            isActive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isActive ? Colors.red : Colors.black,
            size: 22,
          ),
        ),
      ),
    );
  }
}
