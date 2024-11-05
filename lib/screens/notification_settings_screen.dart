import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool previewMessage = true;
  bool previewImage = true;
  bool profilePreview = true;
  bool appAlerts = true;
  bool appSounds = true;
  bool appVibrations = true;
  bool replyAlert = false;
  bool keywordAlert = true;
  bool mentionAlert = true;
  bool _dailyScheduleNotification = true;
  bool _badgeEnabled = true;
  String _notificationSound = '기본 소리';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff), // 전체 배경색 설정
      appBar: AppBar(
        title: Text('알림 및 배지'),
        backgroundColor: Color(0xff73b1e7), // AppBar 배경색 설정
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            '알림 소리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black, // 텍스트 색상 검정으로 변경
            ),
          ),
          ListTile(
            title: Text('알림 소리', style: TextStyle(color: Colors.black)),
            subtitle: Text(_notificationSound, style: TextStyle(color: Colors.black)),
            trailing: Icon(Icons.arrow_forward_ios, color: Color(0xff73b1e7)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('알림 소리 선택', style: TextStyle(color: Colors.black)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text('기본 소리', style: TextStyle(color: Colors.black)),
                        onTap: () {
                          setState(() {
                            _notificationSound = '기본 소리';
                          });
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: Text('기타 소리', style: TextStyle(color: Colors.black)),
                        onTap: () {
                          setState(() {
                            _notificationSound = '기타 소리';
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Text(
            '하루 일정 알림',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SwitchListTile(
            title: Text('하루 일정 알림', style: TextStyle(color: Colors.black)),
            value: _dailyScheduleNotification,
            onChanged: (bool value) {
              setState(() {
                _dailyScheduleNotification = value;
              });
            },
            activeColor: Color(0xff73b1e7), // 스위치 색상 설정
          ),
          SizedBox(height: 20),
          Text(
            '배지',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SwitchListTile(
            title: Text('배지 활성화', style: TextStyle(color: Colors.black)),
            value: _badgeEnabled,
            onChanged: (bool value) {
              setState(() {
                _badgeEnabled = value;
              });
            },
            activeColor: Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: Text('미리보기', style: TextStyle(color: Colors.black)),
            subtitle: Text('푸시 알림이 왔을 때 메시지의 일부를 보여줍니다.', style: TextStyle(color: Colors.black)),
            value: previewMessage,
            onChanged: (value) {
              setState(() {
                previewMessage = value;
              });
            },
            activeColor: Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: Text('사진/이모티콘 미리보기', style: TextStyle(color: Colors.black)),
            value: previewImage,
            onChanged: (value) {
              setState(() {
                previewImage = value;
              });
            },
            activeColor: Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: Text('프로필 미리보기', style: TextStyle(color: Colors.black)),
            value: profilePreview,
            onChanged: (value) {
              setState(() {
                profilePreview = value;
              });
            },
            activeColor: Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: Text('앱 실행 중 알림', style: TextStyle(color: Colors.black)),
            value: appAlerts,
            onChanged: (value) {
              setState(() {
                appAlerts = value;
              });
            },
            activeColor: Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: Text('앱 실행 중 사운드', style: TextStyle(color: Colors.black)),
            value: appSounds,
            onChanged: (value) {
              setState(() {
                appSounds = value;
              });
            },
            activeColor: Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: Text('앱 실행 중 진동', style: TextStyle(color: Colors.black)),
            value: appVibrations,
            onChanged: (value) {
              setState(() {
                appVibrations = value;
              });
            },
            activeColor: Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: Text('답장 메시지 알림', style: TextStyle(color: Colors.black)),
            subtitle: Text('내가 전송한 메시지에 답장이 달리면 채팅방 알림이 꺼져있어도 알림을 받을 수 있습니다.', style: TextStyle(color: Colors.black)),
            value: replyAlert,
            onChanged: (value) {
              setState(() {
                replyAlert = value;
              });
            },
            activeColor: Color(0xff73b1e7),
          ),
          ListTile(
            title: Text('키워드 알림', style: TextStyle(color: Colors.black)),
            trailing: Text(keywordAlert ? '켜짐' : '꺼짐', style: TextStyle(color: Colors.black)),
            onTap: () {
              setState(() {
                keywordAlert = !keywordAlert;
              });
            },
          ),
          SwitchListTile(
            title: Text('일반채팅 멘션 알림', style: TextStyle(color: Colors.black)),
            subtitle: Text('일반채팅방에서 내가 언급된 메시지는 채팅방 알림이 꺼져 있어도 푸시 알림을 받게 됩니다.', style: TextStyle(color: Colors.black)),
            value: mentionAlert,
            onChanged: (value) {
              setState(() {
                mentionAlert = value;
              });
            },
            activeColor: Color(0xff73b1e7),
          ),
        ],
      ),
    );
  }
}
