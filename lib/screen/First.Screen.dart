import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todobest_home/utils/Main.Colors.dart';
import 'package:todobest_home/widgets/App.Icon.dart';
import 'package:todobest_home/widgets/Login.Button.dart';
import 'package:todobest_home/widgets/Sign-Up.Button.dart';
import 'package:todobest_home/widgets/Social.Login.dart';
import 'package:todobest_home/screen/Calender.Screen.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 자동 로그인을 체크합니다.
    checkAutoLogin();
  }

  void checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // SharedPreferences에서 자동 로그인 여부를 확인하고, 설정된 경우 캘린더 화면으로 이동합니다.
    if (prefs.getBool('isAutoLogin') ?? false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CalenderScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MainColors.mainColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1),
                const AppIcon(),
                SizedBox(height: screenHeight * 0.042),
                Text(
                  '환영합니다!',
                  style: TextStyle(
                    color: const Color(0xFF171D1B),
                    fontSize: screenWidth * 0.08,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                const SignUpButton(),
                SizedBox(height: screenHeight * 0.02),
                const LoginButton(),
                SizedBox(height: screenHeight * 0.035),
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
