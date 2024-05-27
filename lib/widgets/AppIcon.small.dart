import 'package:flutter/material.dart';

class AppIconSmall extends StatelessWidget {
  const AppIconSmall({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate the size for the icons based on the screen width
    final iconSize = screenWidth * 0.12; // Adjust the factor as needed

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: iconSize,
            backgroundImage: const AssetImage('assets/images/icon.png'),
          ),
        ],
      ),
    );
  }
}
