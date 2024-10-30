// RankMore.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../service/User_Service.dart';
import '../utils/Themes.Colors.dart';
import 'RankingScreen.dart';
import 'DailyTaskScreen.dart';
import 'WeekTaskScreen.dart';
import 'ChallengeTaskScreen.dart';

class RankMore extends StatefulWidget {
  const RankMore({super.key});

  @override
  _RankMoreState createState() => _RankMoreState();
}

class _RankMoreState extends State<RankMore> {
  int currentExp = 0; // 현재 경험치
  int level = 1; // 초기 레벨 설정
  int maxExp = 10; // 첫 레벨의 총 경험치 요구량
  final UserService userService = UserService(); // UserService 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _updateLevel();
    _loadUserInfo(); // 사용자 정보를 불러오는 함수 호출
  }

  // 사용자 정보를 Firestore에서 불러오는 함수
  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userInfo = await userService.getUserInfo(user.uid);
      if (userInfo != null) {
        setState(() {
          level = userInfo['level'] ?? 1;
          currentExp = userInfo['currentExp'] ?? 0;
          maxExp = userInfo['maxExp'] ?? 10;
        });
      }
    }
  }

  // 레벨과 경험치 업데이트 후 Firestore에 저장하는 함수
  void _updateLevel() {
    while (currentExp >= maxExp) {
      currentExp -= maxExp; // 현재 경험치에서 maxExp를 빼고 남은 경험치로 업데이트
      level++; // 레벨 증가
      maxExp += 10; // 다음 레벨의 총 경험치 요구량을 10씩 증가
    }

    // 업데이트된 정보를 Firestore에 저장
    _saveUserLevelAndExp();
  }

  // Firestore에 레벨과 경험치 저장
  Future<void> _saveUserLevelAndExp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await userService.updateUserLevelAndExp(user.uid, level, currentExp, maxExp);
    }
  }

  // Firebase에서 프로필 이미지 URL 가져오는 함수
  Future<String?> _getProfileImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.photoURL != null) {
      return user!.photoURL;
    } else if (user != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}.png');
        return await ref.getDownloadURL();
      } catch (e) {
        if (kDebugMode) {
          print("프로필 이미지 가져오기 오류: $e");
        }
        return null;
      }
    }
    return null;
  }

  // Firebase에서 사용자 이름을 가져오는 함수
  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? '사용자';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double expRatio = currentExp / maxExp;

    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        title: Text(
          'ToDoBest',
          style: TextStyle(fontSize: 26, color: Theme1Colors.textColor),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff73b1e7),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/icon.png'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                FutureBuilder<String?>(
                  future: _getProfileImageUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: screenWidth * 0.1,
                        backgroundColor: Colors.grey,
                        child: const CircularProgressIndicator(),
                      );
                    }
                    return CircleAvatar(
                      radius: screenWidth * 0.1,
                      backgroundColor: Colors.grey,
                      backgroundImage: snapshot.data != null
                          ? NetworkImage(snapshot.data!)
                          : const AssetImage('assets/profile_placeholder.png')
                      as ImageProvider,
                    );
                  },
                ),
                SizedBox(width: screenWidth * 0.04),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getUserName(),
                      style: TextStyle(
                        fontSize: screenHeight * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lv.$level', // 현재 레벨 표시
                          style: TextStyle(
                            fontSize: screenHeight * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        SizedBox(
                          width: screenWidth * 0.6,
                          child: LinearProgressIndicator(
                            value: expRatio,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                            minHeight: screenHeight * 0.02,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          '$currentExp/$maxExp', // 현재 경험치와 다음 레벨까지의 총 경험치 표시
                          style: TextStyle(
                            fontSize: screenHeight * 0.02,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.05),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: screenWidth * 0.04,
                mainAxisSpacing: screenHeight * 0.03,
                children: [
                  TaskButton(
                    label: '일일과제',
                    color: Color(0xff9ad7f8),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DailyTasksPage()),
                      );
                    },
                    icon: Icons.assignment, // 일일 과제 아이콘
                  ),
                  TaskButton(
                    label: '주간과제',
                    color: Color(0xff9ad7f8),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WeeklyTasksPage()),
                      );
                    },
                    icon: Icons.calendar_view_week, // 주간 과제 아이콘
                  ),
                  TaskButton(
                    label: '랭킹',
                    color: Color(0xff9ad7f8),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RankingPage()),
                      );
                    },
                    icon: Icons.leaderboard, // 랭킹 아이콘
                  ),
                  TaskButton(
                    label: '도전과제',
                    color: Color(0xff9ad7f8),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChallengePage()),
                      );
                    },
                    icon: Icons.flag, // 도전 과제 아이콘
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TaskButton 클래스
class TaskButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final IconData icon; // 아이콘 매개변수 추가

  const TaskButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    required this.icon, // 아이콘 초기화
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 내용 중앙 정렬
        children: [
          Icon(icon, size: 30), // 아이콘 추가 (크기 설정)
          const SizedBox(height: 8), // 아이콘과 레이블 사이의 공간
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
