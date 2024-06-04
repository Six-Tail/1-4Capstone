import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todobest_home/main.dart';
import 'package:todobest_home/screen/First.Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final bool _isLogin = false;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _isLogin ? const App() : const FirstScreen(),
      ),
    );
  }
}
