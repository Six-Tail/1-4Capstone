import 'package:flutter/material.dart';
import '../utils/Themes.Colors.dart';
import 'RankingScreen.dart';
import 'DailyTaskScreen.dart';
import 'WeekTaskScreen.dart';
import 'ChallengeTaskScreen.dart';

class RankMore extends StatelessWidget {
  final int currentExp = 800; // 현재 경험치
  final int maxExp = 1500; // 총 경험치

  const RankMore({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double expRatio = currentExp / maxExp;

    return Scaffold(
      backgroundColor: const Color(0xffc6dff5),
      appBar: AppBar(
        title: Text(
          'ToDoBest',
          style: TextStyle(
            fontSize: 26,
            color: Theme1Colors.textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme1Colors.mainColor,
        leading: BackButton(
          color: Theme1Colors.textColor,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // 알림 기능 추가 가능
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.1,
                  backgroundColor: Colors.grey,
                  backgroundImage: AssetImage('assets/profile_placeholder.png'),
                ),
                SizedBox(width: screenWidth * 0.04),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '홍길동',
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
                          'Lv.999',
                          style: TextStyle(
                            fontSize: screenHeight * 0.025,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          width: screenWidth * 0.6,
                          child: LinearProgressIndicator(
                            value: expRatio,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                            minHeight: screenHeight * 0.02,
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
                    color: Colors.green.shade200,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DailyTasksPage()),
                      );
                    },
                  ),
                  TaskButton(
                    label: '주간과제',
                    color: Colors.green.shade100,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WeeklyTasksPage()),
                      );
                    },
                  ),
                  TaskButton(
                    label: '랭킹',
                    color: Colors.yellow.shade100,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RankingPage()),
                      );
                    },
                  ),
                  TaskButton(
                    label: '도전과제',
                    color: Colors.orange.shade100,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChallengePage()),
                      );
                    },
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

// TaskButton 클래스 파일 내부에 정의
class TaskButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  TaskButton({required this.label, required this.color, required this.onPressed});

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
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
