import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import '../service/User_Service.dart';
import 'authsecession_screen.dart';
import 'feedback_screen.dart';
import 'namedetailscreen.dart';
import 'notification_settings_screen.dart';
import 'calendar_list_screen.dart';
import '../screen/First.Screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PWChange.Screen.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final UserService _userService = UserService();
  String accountType = '';
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

  void _getCurrentUserInfo() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      final userInfo = await _userService.getUserInfo(firebaseUser.uid);

      // Firestore에서 accountType 불러오기
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        setState(() {
          accountType = userDoc.data()?['accountType'] ?? 'ToDoBest 계정';
        });
      }

      // 나머지 사용자 정보 설정
      if (userInfo != null) {
        setState(() {
          userEmail = firebaseUser.email ?? '';
          userName = firebaseUser.displayName ?? 'Unknown';
          userPhone = userInfo['phoneNumber']?.isNotEmpty == true
              ? userInfo['phoneNumber']
              : '전화번호를 설정하세요';
          userName = userInfo['userName'] ?? userName;
          userImage = userInfo['userImage'] ?? userImage;
        });
      }
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (logoutSuccessful) {
      Get.offAll(() => const FirstScreen());
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
              child: const Text('예', style: TextStyle(color: Colors.black)),
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                await _signOut(); // 로그아웃 함수 호출
              },
            ),
            TextButton(
              child: const Text('아니오', style: TextStyle(color: Colors.black)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: userImage.isNotEmpty
                        ? NetworkImage(userImage)
                        : const AssetImage('assets/images/default_profile.png')
                    as ImageProvider,
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
                  final updatedUserInfo = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileDetailScreen(),
                    ),
                  );

                  if (updatedUserInfo != null) {
                    setState(() {
                      userName = updatedUserInfo['userName'];
                      userImage = updatedUserInfo['userImage'];
                    });
                  }
                },
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(accountType),
            subtitle: Text(userEmail),
          ),
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('전화번호'),
            subtitle: Text(userPhone),
          ),
          ListTile(
            title: const Text('내 정보 관리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final updatedUserInfo = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileDetailScreen(),
                ),
              );

              if (updatedUserInfo != null) {
                setState(() {
                  userName = updatedUserInfo['userName'];
                  userImage = updatedUserInfo['userImage'];
                });
              }
            },
          ),
          ListTile(
            title: const Text('계정 비밀번호 변경'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (accountType != 'ToDoBest 계정') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('오류'),
                      content: const Text('ToDoBest 계정 이용자만 가능합니다'),
                      actions: [
                        TextButton(
                          child: const Text("확인"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PWChangeScreen()),
                );
              }
            },
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('시간대'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("알림"),
                    content: const Text("업데이트 중인 서비스입니다"),
                    actions: [
                      TextButton(
                        child: const Text("확인"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('알림 및 배지'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen()),
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
                  builder: (context) =>
                      const CalendarListScreen(),
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
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('ToDoBest pro'),
            subtitle: const Text('광고 제거 및 기능 잠금 해제'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.stars),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("알림"),
                    content: const Text("아직 준비중인 서비스입니다! 이용해주셔서 감사합니다"),
                    actions: [
                      TextButton(
                        child: const Text("확인"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('로그아웃'),
            trailing: const Icon(Icons.chevron_right),
            leading: const Icon(Icons.logout),
            onTap: _showLogoutDialog,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('회원탈퇴'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthSeccessionScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
