import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import '../service/User_Service.dart';
import 'feedback_screen.dart';
import 'namedetailscreen.dart';
import 'notification_settings_screen.dart';
import 'calendar_list_screen.dart';
import '../screen/First.Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PWChange.Screen.dart';

class ManageScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  ManageScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final UserService _userService = UserService();
  String accountType = 'ToDoBest 계정';
  String userEmail = '';
  String userName = '';
  String userImage = '';
  String userPhone = ''; // 전화번호 필드 추가
  firebase_auth.User? firebaseUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUserInfo();
  }

  // 전화번호 변경 함수
  void _changePhoneNumber() async {
    String? newPhoneNumber = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController phoneController = TextEditingController();
        return AlertDialog(
          title: const Text('전화번호 변경'),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: '새 전화번호 입력'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null), // 취소
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(phoneController.text); // 입력된 번호 반환
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    // 입력된 새 전화번호가 있을 경우 업데이트
    if (newPhoneNumber != null && newPhoneNumber.isNotEmpty) {
      setState(() {
        userPhone = newPhoneNumber;
      });
      await _userService.updateUserPhoneNumber(firebaseUser!.uid, newPhoneNumber);
    }
  }

  // 현재 사용자 정보 가져오기
  void _getCurrentUserInfo() async {
    firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // Firebase User 정보 설정
      setState(() {
        userEmail = firebaseUser!.email ?? '';
        userName = firebaseUser!.displayName ?? 'Unknown';
        userImage = firebaseUser!.photoURL ?? 'https://example.com/default_image.jpg';
      });

      // 사용자 Firestore 정보 가져오기
      final userInfo = await _userService.getUserInfo(firebaseUser!.uid);
      setState(() {
        userPhone = userInfo?['phoneNumber'] ?? '전화번호를 설정하세요'; // 저장된 전화번호 불러오기
        userName = userInfo?['userName'] ?? userName; // 저장된 사용자 이름 불러오기
      });

      // 계정 종류 확인
      if (await _isGoogleUser()) {
        setState(() => accountType = 'Google 계정');
      } else if (await _isKakaoUser()) {
        setState(() => accountType = 'Kakao 계정');
      } else if (await _isNaverUser()) {
        setState(() => accountType = 'Naver 계정');
      } else {
        setState(() => accountType = 'ToDoBest 계정');
      }
    }
  }

  Future<bool> _isGoogleUser() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    return await googleSignIn.isSignedIn();
  }

  Future<bool> _isKakaoUser() async {
    try {
      final kakao.User user = await kakao.UserApi.instance.me();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isNaverUser() async {
    try {
      final currentToken = await FlutterNaverLogin.currentAccessToken;
      return currentToken != null && currentToken.accessToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // 로그아웃 함수
  Future<void> _signOut() async {
    bool logoutSuccessful = true;

    // Firebase 로그아웃 시도
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
      if (kDebugMode) {
        print('파이어베이스 로그아웃 성공');
      }
    } catch (error) {
      if (kDebugMode) {
        print('파이어베이스 로그아웃 실패 $error');
      }
      logoutSuccessful = false;
    }

    // 소셜 로그아웃 개별 시도
    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
      // 로그아웃 후 SharedPreferences에 저장된 네이버 로그인 상태 초기화
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      if (kDebugMode) {
        print('네이버 로그아웃 및 SharedPreferences 초기화 성공');
      }
    } catch (e) {
      if (kDebugMode) {
        print("네이버 로그아웃 실패: $e");
      }
    }


    try {
      await GoogleSignIn().signOut();
      if (kDebugMode) {
        print('구글 로그아웃 성공');
      }
    } catch (e) {
      if (kDebugMode) {
        print("구글 로그아웃 실패: $e");
      }
    }

    try {
      await kakao.UserApi.instance.logout();
      if (kDebugMode) {
        print('카카오 로그아웃 성공');
      }
    } catch (e) {
      if (kDebugMode) {
        print("카카오 로그아웃 실패: $e");
      }
    }

    // SharedPreferences 초기화로 자동 로그인 상태 해제
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // 로그아웃이 성공한 경우 FirstScreen으로 이동하고 모든 화면 제거
    if (logoutSuccessful) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const FirstScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  // 로그아웃 확인 다이얼로그
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              child: const Text('예'),
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                await _signOut(); // 로그아웃 함수 호출
              },
            ),
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: const Color(0xffffffff),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(userImage),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () async {
                    final updatedUserName = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileDetailScreen()),
                    );

                    // ProfileDetailScreen에서 변경된 userName을 가져와서 업데이트
                    if (updatedUserName != null) {
                      setState(() {
                        userName = updatedUserName;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(accountType), // 계정 종류 (Google, Kakao, Naver, ToDoBest)
            subtitle: Text(userEmail), // 이메일 주소
          ),
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('전화번호'),
            subtitle: Text(userPhone),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _changePhoneNumber,
            ),
          ),
          ListTile(
            title: const Text('내 정보 관리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final updatedUserName = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileDetailScreen(),
                ),
              );

              // ProfileDetailScreen에서 변경된 userName을 가져와서 업데이트
              if (updatedUserName != null) {
                setState(() {
                  userName = updatedUserName;
                });
              }
            },
          ),
          ListTile(
            title: Text('계정 비밀번호 변경'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PWChangeScreen()),
              );
            },
          ),
          const Divider(color: Colors.grey),
          const ListTile(
            leading: Icon(Icons.access_time),
            title: Text('시간대'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('알림 및 배지'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('캘린더 목록'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarListScreen(isDarkMode: widget.isDarkMode),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('피드백'),
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
          const Divider(),
        ],
      ),
    );
  }
}
