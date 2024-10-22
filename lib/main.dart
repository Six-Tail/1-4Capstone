import 'package:firebase_auth/firebase_auth.dart'
    as firebase; // Firebase Auth에 별칭 부여
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:todobest_home/Router.dart';
import 'package:todobest_home/screen/First.Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // Kakao SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '12983a04412626098bd000dd862a742b',
    javaScriptAppKey: '75a73786836d92e7d0ba16f757d36355',
  );

  // 날짜 포맷 초기화
  initializeDateFormatting().then((_) => runApp(const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TodoBest',
      home: const AuthWrapper(), // AuthWrapper 로그인 상태를 관리
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

// 로그인 상태를 관리하는 위젯
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase.User?>(
      stream: firebase.FirebaseAuth.instance.authStateChanges(),
      // Firebase Auth 상태 변화 감지
      builder: (context, snapshot) {
        // 사용자가 로그인되어 있으면 캘린더 화면으로 이동, 아니면 로그인 화면으로 이동
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // 로딩 중 화면
        } else if (snapshot.hasData) {
          // 사용자가 이미 로그인되어 있는 경우
          return RouterPage(); // 로그인한 경우 캘린더 화면
        } else {
          // 사용자가 로그인하지 않은 경우
          return const FirstScreen(); // 로그인하지 않은 경우 로그인 화면
        }
      },
    );
  }
}
