import 'package:flutter/material.dart';
import 'package:todobest_home/utils/Main.Colors.dart';
import 'package:todobest_home/widgets/Login.Button.dart';
import 'package:todobest_home/widgets/Sign-Up.Button.dart';
import 'package:todobest_home/widgets/Social.Login.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(100.0),
                  alignment: Alignment.center,
                  child: Text(
                    'ToDoBest',
                    style: TextStyle(
                      color: MainColors.textColor,
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '환영합니다!',
                  style: TextStyle(
                    color: const Color(0xFF171D1B),
                    fontSize: screenWidth * 0.08,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                const SignUpButton(),
                SizedBox(height: screenHeight * 0.02),
                const LoginButton(),
                SizedBox(height: screenHeight * 0.03),
                Column(
                  children: [
                    Container(
                      width: screenWidth * 0.64,
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
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
