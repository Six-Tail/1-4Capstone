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
  int maxExp = 10;
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserInfo(); // 페이지로 돌아올 때마다 사용자 정보 갱신
  }

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

  void _updateLevel() {
    while (currentExp >= maxExp) {
      level += 1;
      currentExp -= maxExp;
      maxExp = (maxExp * 1.2).round();
    }
    _saveUserLevelAndExp();
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
                    Row(
                      children: [
                        Text(
                          'Lv.$level',
                          style: TextStyle(
                            fontSize: screenHeight * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          _getUserName(),
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
                      '$currentExp/$maxExp',
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
                    label: '일일과제',
                    color: const Color(0xff9ad7f8),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DailyTasksPage()),
                      ).then((_) => _loadUserInfo()); // 돌아오면 정보 갱신
                    },
                    icon: Icons.assignment,
                  ),
                  TaskButton(
                    label: '주간과제',
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
