import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:todobest_home/rank/task_button.dart';
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
  int currentExp = 0;
  int level = 1;
  int maxExp = 100;
  final UserService userService = UserService();
  Color levelTextColor = Colors.black; // 초기 색상은 검정색으로 설정
  String userName = '사용자'; // 최신 사용자 이름을 저장할 변수

  // 레벨에 따른 색상 배열 (1~9레벨은 연한 파랑, 10레벨부터 다른 색상 사용)
  final List<Color> levelColors = [
    Colors.lightBlueAccent,  // 1~9 레벨
    Colors.deepPurpleAccent,  // 10~19 레벨
    Colors.amberAccent,       // 20~29 레벨
    Colors.redAccent,         // 30~39 레벨
    Colors.pinkAccent,        // 40~49 레벨
    Colors.cyanAccent,        // 50~59 레벨
    Colors.yellowAccent,      // 60~69 레벨
    Colors.lightGreenAccent,  // 70~79 레벨
    Colors.deepOrange,        // 80~89 레벨
    Colors.purpleAccent,      // 90~99 레벨
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Firestore에서 사용자 정보 가져오기
      final userInfo = await userService.getUserInfo(user.uid);
      if (userInfo != null) {
        setState(() {
          level = userInfo['level'] ?? 1;
          currentExp = userInfo['currentExp'] ?? 0;
          maxExp = userInfo['maxExp'] ?? 100;
          userName = userInfo['userName'] ?? '사용자'; // 최신 사용자 이름 설정
        });

        _setLevelTextColor(); // 색상 설정
        _updateLevel(); // 레벨 업데이트 체크
      }
    }
  }

  void _updateLevel() {
    final updatedData = userService.updateLevel(currentExp, level, maxExp);
    setState(() {
      level = updatedData['level']!;
      currentExp = updatedData['currentExp']!;
      maxExp = updatedData['maxExp']!;
      _setLevelTextColor(); // 레벨 텍스트 색상 설정
    });
    _saveUserLevelAndExp();
  }

  void _setLevelTextColor() {
    if (level < 10) {
      levelTextColor = Colors.black; // 1~9레벨은 검정색
    } else {
      // 색상 배열을 반복해서 사용
      int colorIndex = (level ~/ 10 - 1) % levelColors.length; // 색상 배열 길이로 나눈 나머지 사용
      levelTextColor = levelColors[colorIndex]; // 색상 설정
    }
  }

  Future<void> _saveUserLevelAndExp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await userService.updateUserLevelAndExp(user.uid, level, currentExp, maxExp);
    }
  }

  Future<String?> _getProfileImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.photoURL != null) {
      return user!.photoURL;
    } else if (user != null) {
      try {
        final ref = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.png');
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

  // 경험치 포맷팅 함수
  String _formatExperience(int exp) {
    if (exp < 10000) return exp.toString();
    if (exp < 100000000) return '${(exp / 10000).toStringAsFixed(1)}만';
    if (exp < 1000000000000) return '${(exp / 100000000).toStringAsFixed(1)}억';
    return '${(exp / 1000000000000).toStringAsFixed(1)}조';
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
                    Row(
                      children: [
                        Text(
                          'Lv.$level',
                          style: TextStyle(
                            fontSize: screenHeight * 0.03,
                            fontWeight: FontWeight.bold,
                            color: levelTextColor, // 레벨 텍스트 색상 적용
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: screenHeight * 0.028,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    SizedBox(
                      width: screenWidth * 0.6,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          LinearProgressIndicator(
                            value: expRatio,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.greenAccent),
                            minHeight: screenHeight * 0.02,
                          ),
                          Text(
                            '${(expRatio * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: screenHeight * 0.018,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      '${_formatExperience(currentExp)}/${_formatExperience(maxExp)}', // 포맷팅된 경험치 표시
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.06),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: screenWidth * 0.04,
                mainAxisSpacing: screenHeight * 0.03,
                children: [
                  TaskButton(
                    label: '일간 미션',
                    color: const Color(0xff9ad7f8),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DailyTasksPage()),
                      ).then((_) => _loadUserInfo()); // 돌아오면 정보 갱신
                    },
                    icon: Icons.assignment,
                  ),
                  TaskButton(
                    label: '주간 미션',
                    color: const Color(0xff9ad7f8),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WeeklyTasksPage()),
                      ).then((_) => _loadUserInfo());
                    },
                    icon: Icons.calendar_view_week,
                  ),
                  TaskButton(
                    label: '랭킹',
                    color: const Color(0xff9ad7f8),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RankingPage()),
                      ).then((_) => _loadUserInfo());
                    },
                    icon: Icons.leaderboard,
                  ),
                  TaskButton(
                    label: '도전과제',
                    color: const Color(0xff9ad7f8),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChallengePage()),
                      ).then((_) => _loadUserInfo());
                    },
                    icon: Icons.flag,
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
