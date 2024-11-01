import 'package:flutter/material.dart';
import 'package:todobest_home/screens/manage_screen.dart';

class UserProfileScreen extends StatelessWidget {
  get toggleTheme => null;

  get isDarkMode => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('정보 관리')),
      body: ListView(
        children: [
          ListTile(
            title: Text('전화번호'),
            subtitle: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/change-phone-number');
              },
              child: Text(
                '+82 10-2730-4759',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('이메일'),
            subtitle: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/change-email');
              },
              child: Text(
                'peterishappy@naver.com',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('계정 관리'),
            subtitle: Text('계정 정보를 변경합니다.'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode)),
              );
            },
          ),
          SwitchListTile(
            title: Text('생일 알림'),
            subtitle: Text(
              '내 프로필에 생일 아이콘을 표시하고, 친구목록 혹은 생일을 활용한 톡 서비스를 통해 내 생일 소식을 알려줍니다.',
            ),
            value: true,
            onChanged: (bool value) {},
            activeColor: Colors.blue,
          ),
          SwitchListTile(
            title: Text('Wi-Fi에서만 배경 자동재생'),
            subtitle: Text(
              '프로필의 배경 동영상을 Wi-Fi 환경에서만 자동 재생합니다. 같은 동영상은 최초 1회 재생 시에만 데이터가 소모됩니다.',
            ),
            value: false,
            onChanged: (bool value) {},
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
