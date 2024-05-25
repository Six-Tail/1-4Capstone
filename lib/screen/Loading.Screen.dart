import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todobest_home/screen/First.Screen.dart';
import 'package:todobest_home/utils/Main.Colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Timer(const Duration(seconds: 1), () {
      Get.to(const FirstScreen());
    });
    return Scaffold(
      backgroundColor: MainColors.mainColor,
      body: Center(
        child: Text(
          'ToDoBest',
          style: TextStyle(
            color: MainColors.textColor,
            fontSize: screenWidth * 0.1, // Responsive font size
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
