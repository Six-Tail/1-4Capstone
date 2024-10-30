import 'package:flutter/material.dart';

import 'account_info_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String currentPhoneNumber = '+82 10-2730-4759';
  String currentEmail = 'peterishappy@naver.com';
  bool _birthdayalarm = true;
  bool _automaticgeneration = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '내 정보 관리',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            ListTile(
              title: Text(
                '전화번호',
              ),
              trailing: Text(
                currentPhoneNumber,
              ),
            ),
            Divider(color: Colors.grey), // 구분선 추가
            ListTile(
              title: Text(
                '이메일',
              ),
              trailing: Text(
                currentEmail,
              ),
            ),
            Divider(color: Colors.grey), // 구분선 추가
            ListTile(
              title: Text(
                '계정 관리',
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountInfoScreen()),
                );
              },
            ),
            Divider(color: Colors.grey), // 구분선 추가
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('고급 설정', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const ListTile(
              leading: Icon(Icons.history),
              title: Text('내 홈 과거 데이터 보기'),
              subtitle: Text('현재 지원하지 않는 내 홈의 과거 데이터를 열람할 수 있습니다.'),
            ),
            SwitchListTile(
              title: const Text('생일 알림'),
              subtitle: const Text(
                  '내 프로필에 생일 아이콘을 표시하고, 친구 목록 또는 생일 알림 서비스를 통해 생일을 알릴 수 있습니다.'),
              value: true,
              onChanged: (bool value) {},
            ),
            SwitchListTile(
              title: const Text('Wi-Fi에서만 배경 자동재생'),
              subtitle: const Text('프로필 배경 동영상을 Wi-Fi 환경에서만 자동 재생합니다.'),
              value: false,
              onChanged: (bool value) {},
            ),

          ],
        ),
      ),
    );
  }
}