import 'package:flutter/material.dart';
import 'package:todobest_home/screens/account_info_screen.dart';
import 'event_edit_screen.dart';
import 'image_picker.dart';
import 'feedback_screen.dart';
import 'notification_settings_screen.dart';
import 'calendar_list_screen.dart';
import 'login_management_screen.dart'; // login_management_screen.dart 파일 임포트



class ManageScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  ManageScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  String selectedHoliday = '한국';
  String selectedLanguage = '한국';
  List<bool> showTimezone = [true, false];
  List<bool> showLunar = [true, false];
  List<bool> showScheduleHistory = [true, false];
  List<bool> showRecommendedPhotos = [true, false];

  // 토글 버튼 스타일
  Widget _buildToggleButton(List<bool> isSelected) {
    return ToggleButtons(
      isSelected: isSelected,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = i == index;
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      fillColor: Colors.grey[700],
      color: Colors.grey,
      constraints: BoxConstraints(minWidth: 60.0, minHeight: 40.0),
      children: const [
        Text('표시'),
        Text('비표시'),
      ],
    );
  }

  // 휴일 선택 모달 창
  void _showHolidayPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('한국'),
                onTap: () {
                  setState(() {
                    selectedHoliday = '한국';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('미국'),
                onTap: () {
                  setState(() {
                    selectedHoliday = '미국';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('일본'),
                onTap: () {
                  setState(() {
                    selectedHoliday = '일본';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 언어 선택 모달 창
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('한국'),
                onTap: () {
                  setState(() {
                    selectedLanguage = '한국';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('미국'),
                onTap: () {
                  setState(() {
                    selectedLanguage = '미국';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('일본'),
                onTap: () {
                  setState(() {
                    selectedLanguage = '일본';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage('https://example.com/profile_image.jpg'),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '정세운',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '+82 10-2730-4759',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AccountSettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('ToDoBest 계정'),
            subtitle: Text('peterishappy@naver.com'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountInfoScreen()),
              );
            },
          ),

          const Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('언어'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedLanguage,
                  style: TextStyle(color: Colors.grey),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16.0),
              ],
            ),
            onTap: _showLanguagePicker,
          ),
          ListTile(
            leading: Icon(Icons.event_available),
            title: Text('휴일'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedHoliday,
                  style: TextStyle(color: Colors.grey),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16.0),
              ],
            ),
            onTap: _showHolidayPicker,
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text('시간대'),
            trailing: _buildToggleButton(showTimezone),
          ),
          ListTile(
            leading: Icon(Icons.brightness_2),
            title: Text('음력'),
            trailing: _buildToggleButton(showLunar),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('일정 작성 기록'),
            trailing: _buildToggleButton(showScheduleHistory),
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('추천 사진'),
            trailing: _buildToggleButton(showRecommendedPhotos),
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('이벤트 편집'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventEditScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('알림 및 배지'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('피드백'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('캘린더 목록'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarListScreen(isDarkMode: widget.isDarkMode),
                ),
              );
            },
          ),
          const ListTile(
            title: Text('ToDoBest pro'),
            subtitle: Text('광고 제거 및 기능 잠금 해제'),
            trailing: Icon(Icons.chevron_right),
            leading: Icon(Icons.stars),
          ),
          const ListTile(
            title: Text('로그아웃'),
            trailing: Icon(Icons.chevron_right),
            leading: Icon(Icons.logout),
          ),
          Divider(),
          ListTile(
            title: Text('화면 테마'),
            trailing: Switch(
              value: widget.isDarkMode,
              onChanged: (bool value) {
                widget.toggleTheme(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
