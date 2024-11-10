import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  final List<Color> levelColors = [
    Colors.lightBlueAccent,
    Colors.deepPurpleAccent,
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
    Colors.yellowAccent,
    Colors.lightGreenAccent,
    Colors.deepOrange,
    Colors.purpleAccent,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userInfo = await userService.getUserInfo(user.uid);
      if (userInfo != null) {
        setState(() {
          level = userInfo['level'] ?? 1;
          currentExp = userInfo['currentExp'] ?? 0;
          maxExp = userInfo['maxExp'] ?? 100;
          userName = userInfo['userName'] ?? '사용자';
        });

        _setLevelTextColor();
        _updateLevel();
      }
    }
  }

  void _updateLevel() {
    final updatedData = userService.updateLevel(currentExp, level, maxExp);
    setState(() {
      level = updatedData['level']!;
      currentExp = updatedData['currentExp']!;
      maxExp = updatedData['maxExp']!;
      _setLevelTextColor();
    });
    _saveUserLevelAndExp();
  }

  void _setLevelTextColor() {
    if (level < 10) {
      levelTextColor = Colors.black;
    } else {
      int colorIndex = (level ~/ 10 - 1) % levelColors.length;
      levelTextColor = levelColors[colorIndex];
    }
  }

  Future<void> _saveUserLevelAndExp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await userService.updateUserLevelAndExp(
          user.uid, level, currentExp, maxExp);
    }
  }

  Future<String?> _getProfileImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userImage = userDoc.data()?['userImage'];
          if (userImage != null && userImage is String) {
            return userImage;
          }
        }
        return user.photoURL ?? 'assets/profile_placeholder.png';
      } catch (e) {
        return 'assets/profile_placeholder.png';
      }
    }
    return null;
  }

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
        title: Image.asset(
          'assets/images/icon.png',
          width: screenWidth * 0.12,
          height: screenHeight * 0.12,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffffffff),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 프로필 아이콘, 레벨, 이름, 경험치바 감싸는 컨테이너 추가
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                children: [
                  FutureBuilder<String?>(
                    future: _getProfileImageUrl(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircleAvatar(
                          radius: screenWidth * 0.1,
                          backgroundColor: Colors.white,
                          child: const CircularProgressIndicator(),
                        );
                      }
                      return CircleAvatar(
                        radius: screenWidth * 0.1,
                        backgroundColor: Colors.white,
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
                              color: levelTextColor,
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
                        width: screenWidth * 0.58,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            LinearProgressIndicator(
                              value: expRatio,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xff73b1e7)),
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
                        '${_formatExperience(currentExp)}/${_formatExperience(maxExp)}',
                        style: TextStyle(
                          fontSize: screenHeight * 0.02,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                    color: const Color(0xffcae1f6),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DailyTasksPage()),
                      ).then((_) => _loadUserInfo());
                    },
                    icon: Icons.assignment,
                  ),
                  TaskButton(
                    label: '주간 미션',
                    color: const Color(0xffcae1f6),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WeeklyTasksPage()),
                      ).then((_) => _loadUserInfo());
                    },
                    icon: Icons.calendar_view_week,
                  ),
                  TaskButton(
                    label: '랭킹',
                    color: const Color(0xffcae1f6),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RankingPage()),
                      ).then((_) => _loadUserInfo());
                    },
                    icon: Icons.leaderboard,
                  ),
                  TaskButton(
                    label: '도전과제',
                    color: const Color(0xffcae1f6),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChallengePage()),
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
