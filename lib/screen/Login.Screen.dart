import 'package:flutter/material.dart';
import 'package:todobest_home/utils/Main.Colors.dart';
import 'package:todobest_home/widgets/App.Icon.dart';
import 'package:todobest_home/widgets/Login.TextBox.dart';
import 'package:todobest_home/widgets/LoginScreen.Button.dart';

import '../widgets/Social.Login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인 화면'),
        backgroundColor: MainColors.mainColor,
      ),
      backgroundColor: MainColors.mainColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.035),
                const AppIcon(),
                SizedBox(height: screenHeight * 0.01),
                const LoginTextBox(),
                SizedBox(height: screenHeight * 0.005),
                const LoginScreenButton(),
                SizedBox(height: screenHeight * 0.03),
                Column(
                  children: [
                    Container(
                      width: screenWidth * 0.64,
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.8,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Colors.black26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                const SocialLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
