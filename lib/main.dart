import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:todobest_home/screen/Splash.Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //firebase login
  await Firebase.initializeApp();

  //kako login
  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '12983a04412626098bd000dd862a742b',
    javaScriptAppKey: '75a73786836d92e7d0ba16f757d36355',
  );

  runApp(const SplashScreen());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp();
  }
}
