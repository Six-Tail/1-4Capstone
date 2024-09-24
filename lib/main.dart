import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:todobest_home/screen/Splash.Screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // Kakao SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '12983a04412626098bd000dd862a742b',
    javaScriptAppKey: '75a73786836d92e7d0ba16f757d36355',
  );

<<<<<<< HEAD
  initializeDateFormatting().then((_) => runApp(const SplashScreen()));
=======
  runApp(const App());
>>>>>>> ecadf1eac59919b550137de0e2f54082e40b19cb
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      home: SplashScreen(), // 앱 시작 시 표시되는 스플래시 화면
    );
  }
}
