import 'package:flutter/material.dart';
import 'dart:io';

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보 관리'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('전화번호', style: TextStyle(color: Colors.white)),
            subtitle: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/change-phone-number');
              },
              child: Text(
                '+82 10-2730-4759',
                style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
              ),
            ),
          ),
          ListTile(
            title: Text('이메일', style: TextStyle(color: Colors.white)),
            subtitle: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/change-email');
              },
              child: Text(
                'peterishappy@naver.com',
                style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
              ),
            ),
          ),
          ListTile(
            title: Text('기기 정보', style: TextStyle(color: Colors.white)),
            subtitle: FutureBuilder<String>(
              future: _getDeviceName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white70));
                } else {
                  return Text(snapshot.data ?? 'Unknown device', style: TextStyle(color: Colors.white70));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getDeviceName() async {
    if (Platform.isAndroid) {
      return 'Android Device';
    } else if (Platform.isIOS) {
      return 'iOS Device';
    } else {
      return 'Unknown Device';
    }
  }
}
