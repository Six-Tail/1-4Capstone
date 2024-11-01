import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../screen/First.Screen.dart';
import 'feedback_screen.dart';
import 'namedetailscreen.dart';
import 'notification_settings_screen.dart';
import 'calendar_list_screen.dart';

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

  // 로그아웃 함수
  Future<void> _signOut() async {
    bool logoutSuccessful = true;

    try {
      await FirebaseAuth.instance.signOut();
      if (kDebugMode) {
        print('파이어베이스 로그아웃 성공');
      }
    } catch (error) {
      print('파이어베이스 로그아웃 실패 $error');
    }

    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
      if (kDebugMode) {
        print('네이버 로그아웃 성공');
      }
    } catch (error) {
      print('네이버 로그아웃 실패 $error');
    }

    try {
      await GoogleSignIn().signOut();
      if (kDebugMode) {
        print('구글 로그아웃 성공');
      }
    } catch (error) {
      print('구글 로그아웃 실패 $error');
    }

    try {
      await UserApi.instance.logout();
      if (kDebugMode) {
        print('카카오 로그아웃 성공, SDK에서 토큰 삭제');
      }
    } catch (error) {
      print('카카오 로그아웃 실패 $error');
    }

    if (logoutSuccessful) {
      // 로그아웃 완료 후 첫 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => FirstScreen()),
            (route) => false,
      );
    }
  }

  // 로그아웃 확인 다이얼로그
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃'),
          content: Text('로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('예'),
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                await _signOut(); // 로그아웃 함수 호출
              },
            ),
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Color(0xffffffff),
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
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileDetailScreen()),
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
          ),
          ListTile(
            leading: Icon(Icons.call),
            title: Text('전화번호'),
            subtitle: Text('010-2900-9686'),
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
            title: Text('계정 비밀번호 변경'),
            trailing: Icon(Icons.chevron_right),
          ),

          const Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text('시간대'),
            trailing: _buildToggleButton(showTimezone),
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
          const ListTile(
            title: Text('ToDoBest pro'),
            subtitle: Text('광고 제거 및 기능 잠금 해제'),
            trailing: Icon(Icons.chevron_right),
            leading: Icon(Icons.stars),
          ),
          ListTile(
            title: const Text('로그아웃'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.logout),
            onTap: _showLogoutDialog,
          ),
          Divider(),
        ],
      ),
    );
  }
}