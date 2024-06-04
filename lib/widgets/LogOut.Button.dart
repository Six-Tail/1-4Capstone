import 'package:flutter/foundation.dart';
// LogOut.Button.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:todobest_home/screen/First.Screen.dart';

class LogOutButton extends StatefulWidget {
  const LogOutButton({super.key});

  @override
  State<LogOutButton> createState() => _LogOutButtonState();
}

class _LogOutButtonState extends State<LogOutButton> {
  Future<void> _signOut() async {
    bool logoutSuccessful = true;

    try {
      await FirebaseAuth.instance.signOut();
      logoutSuccessful = true;
      if (kDebugMode) {
        print('파이어베이스 로그아웃 성공');
      }
    } catch (error) {
      if (kDebugMode) {
        print('파이어베이스 로그아웃 실패 $error');
      }
    }

    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
      logoutSuccessful = true;
      if (kDebugMode) {
        print('네이버 로그아웃 성공');
      }
    } catch (error) {
      if (kDebugMode) {
        print('네이버 로그아웃 실패 $error');
      }
    }

    try {
      await GoogleSignIn().signOut();
      logoutSuccessful = true;
      if (kDebugMode) {
        print('구글 로그아웃 성공');
      }
    } catch (error) {
      if (kDebugMode) {
        print('구글 로그아웃 실패 $error');
      }
    }

    try {
      await UserApi.instance.logout();
      logoutSuccessful = true;
      if (kDebugMode) {
        print('카카오 로그아웃 성공, SDK에서 토큰 삭제');
      }
    } catch (error) {
      if (kDebugMode) {
        print('카카오 로그아웃 실패, SDK에서 토큰 삭제 $error');
      }
    }

    if (logoutSuccessful) {
      Get.to(() => const FirstScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await _signOut();
      },
      child: const Text('Log Out'),
    );
  }
}