import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todobest_home/utils/Main.Colors.dart';
import 'package:todobest_home/widgets/AppIcon.small.dart';
import 'package:todobest_home/widgets/SignUp.TextBox.dart';
import 'package:todobest_home/widgets/SingUpScreen.Button.dart';

import 'Login.Screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입 화면'),
        backgroundColor: MainColors.mainColor,
      ),
      backgroundColor: MainColors.mainColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.04),
                const AppIconSmall(),
                SizedBox(height: screenHeight * 0.06),
                const SignUpTextBox(),
                SizedBox(height: screenHeight * 0.16),
                const SignUpScreenButton(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: MainColors.mainColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '이미 계정이 있으신가요?',
              style: TextStyle(
                color: const Color(0x7F747775),
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
                fontSize: screenWidth * 0.03,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            GestureDetector(
              onTap: () {
                if (kDebugMode) {
                  print('Login');
                }
                Get.to(() => const LoginScreen()); // Navigate to LoginScreen
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: MainColors.textColor,
                      width: 2.0
                    )
                  )
                ),
                child: Row(
                  children: [
                    Text(
                      '기존 계정으로 로그인',
                      style: TextStyle(
                        color: MainColors.textColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Roboto',
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}