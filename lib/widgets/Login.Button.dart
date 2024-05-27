import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX package
import 'package:todobest_home/utils/Main.Colors.dart';
import 'package:todobest_home/screen/Login.Screen.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        if (kDebugMode) {
          print('Login');
        }
        Get.to(() => const LoginScreen()); // Navigate to LoginScreen
      },
      child: Container(
        alignment: Alignment.center,
        height: screenHeight * 0.068,
        width: screenWidth * 0.8,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 3, color: Color(0xFFFDB082)),
            borderRadius: BorderRadius.circular(33),
          ),
        ),
        child: Text(
          '기존 계정으로 로그인',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: MainColors.textColor,
            fontSize: screenHeight * 0.022,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }
}
