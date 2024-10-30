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
      appBar: AppBar(
        title: Text('알림 및 배지'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
        // 알림 소리 설정
        Text('알림 소리', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListTile(
          title: Text('알림 소리'),
          subtitle: Text(_notificationSound),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            // 알림 소리 선택 로직
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('알림 소리 선택'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text('기본 소리'),
                      onTap: () {
                        setState(() {
                          _notificationSound = '기본 소리';
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: Text('기타 소리'),
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

        // 하루 일정 알림 소제목 및 설정
        Text('하루 일정 알림', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SwitchListTile(
          title: Text('하루 일정 알림'),
          value: _dailyScheduleNotification,
          onChanged: (bool value) {
            setState(() {
              _dailyScheduleNotification = value;
            });
          },
        ),
        SizedBox(height: 20),

    // 배지 소제목 및 설정
    Text('배지', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    SwitchListTile(
    title: Text('배지 활성화'),
    value: _badgeEnabled,
    onChanged: (bool value) {
      setState(() {
        _badgeEnabled = value;
      });
    },
    ),

        // 하루 일정 알림 소제목 및 설정
        Text('하루 일정 알림', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: Text('미리보기'),
            subtitle: Text('푸시 알림이 왔을 때 메시지의 일부를 보여줍니다.'),
            value: previewMessage,
            onChanged: (value) {
              setState(() {
                previewMessage = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('사진/이모티콘 미리보기'),
            value: previewImage,
            onChanged: (value) {
              setState(() {
                previewImage = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('프로필 미리보기'),
            value: profilePreview,
            onChanged: (value) {
              setState(() {
                profilePreview = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('앱 실행 중 알림'),
            value: appAlerts,
            onChanged: (value) {
              setState(() {
                appAlerts = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('앱 실행 중 사운드'),
            value: appSounds,
            onChanged: (value) {
              setState(() {
                appSounds = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('앱 실행 중 진동'),
            value: appVibrations,
            onChanged: (value) {
              setState(() {
                appVibrations = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('답장 메시지 알림'),
            subtitle: Text('내가 전송한 메시지에 답장이 달리면 채팅방 알림이 꺼져있어도 알림을 받을 수 있습니다.'),
            value: replyAlert,
            onChanged: (value) {
              setState(() {
                replyAlert = value;
              });
            },
          ),
          ListTile(
            title: Text('키워드 알림'),
            trailing: Text(keywordAlert ? '켜짐' : '꺼짐'),
            onTap: () {
              setState(() {
                keywordAlert = !keywordAlert;
              });
            },
          ),
          SwitchListTile(
            title: Text('일반채팅 멘션 알림'),
            subtitle: Text('일반채팅방에서 내가 언급된 메시지는 채팅방 알림이 꺼져 있어도 푸시 알림을 받게 됩니다.'),
            value: mentionAlert,
            onChanged: (value) {
              setState(() {
                mentionAlert = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
