// login_management_screen.dart
import 'package:flutter/material.dart';

class LoginManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 관리'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('로그인 이력 조회'),
            onTap: () {
              // 로그인 이력 조회 화면으로 이동 코드 추가
            },
          ),
          ListTile(
            title: Text('현재 로그인 정보 관리'),
            onTap: () {
              // 현재 로그인 정보 관리 화면으로 이동 코드 추가
            },
          ),
          ListTile(
            title: Text('간편 로그인 정보 관리'),
            onTap: () {
              // 간편 로그인 정보 관리 화면으로 이동 코드 추가
            },
          ),
        ],
      ),
    );
  }
}
