import 'package:flutter/material.dart';
import 'package:todobest_home/screens/profiledetailscreen.dart';
import 'login_management_screen.dart'; // login_management_screen.dart 파일 임포트


class AccountInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계정 정보'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('이메일'),
            subtitle: Text('peterishappy@naver.com'),
          ),
          ListTile(
            title: Text('전화번호'),
            subtitle: Text('+82 10-27**-47**'),
          ),
          ListTile(
            title: Text('내 정보 관리'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileDetailScreen(),
                ),
              );
              },
          ),
          ListTile(
            title: Text('연락처 관리'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: Text('계정 비밀번호 변경'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: Text('로그인 관리'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
