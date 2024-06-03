import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todobest_home/screen/Calender.Screen.dart';
import 'package:todobest_home/screen/First.Screen.dart';
import 'package:todobest_home/utils/Main.Colors.dart';
import 'package:todobest_home/widgets/App.Icon.dart';
import 'package:todobest_home/widgets/Login.TextBox.dart';
import 'package:todobest_home/widgets/Social.Login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 자동 로그인 체크 함수
    void checkAutoLogin() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        Get.to(() => const CalenderScreen());
      }
    }

    // 화면이 처음 로드될 때 자동 로그인 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAutoLogin();
    });

    return GestureDetector(
      onTap: () {
        //포커스 해제
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: MainColors.mainColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.to(() => const FirstScreen());
            },
          ),
        ),
        backgroundColor: MainColors.mainColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.035),
                  const AppIcon(),
                  SizedBox(height: screenHeight * 0.01),
                  const LoginTextBox(),
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
      ),
    );
  }
}
