import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todobest_home/screen/Sign-Up.Screen.dart';
import 'package:todobest_home/utils/Main.Colors.dart';

class SignUpButton extends StatelessWidget {
  const SignUpButton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('Sign-Up');
        }
        Get.to(() => const SignUpScreen());
      },
      child: Container(
        alignment: Alignment.center,
        height: screenHeight * 0.068,
        width: screenWidth * 0.8,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.98, -0.18),
            end: Alignment(-0.98, 0.18),
            colors: [Color(0xFFFBDD94), Color(0xFFFDB082), Color(0xFFE05C41)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(33),
          ),
        ),
        child: Text(
            '새로운 계정 만들기',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MainColors.mainColor,
            fontSize: screenHeight * 0.022,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }
}
