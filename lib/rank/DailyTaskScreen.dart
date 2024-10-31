import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../service/User_Service.dart';

class DailyTasksPage extends StatefulWidget {
  @override
  _DailyTasksPageState createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends State<DailyTasksPage> {
  final UserService userService = UserService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  List<Task> dailyTasks = [
    Task(name: 'Exercise', isCompleted: false, xp: 50),
    Task(name: 'Read a book', isCompleted: false, xp: 30),
    Task(name: 'Meditation', isCompleted: false, xp: 20),
  ];

  void completeTask(int index) async {
    if (currentUser == null) return; // 로그인된 사용자가 없으면 리턴

    setState(() {
      dailyTasks[index].isCompleted = !dailyTasks[index].isCompleted;
    });

    if (dailyTasks[index].isCompleted) {
      // 사용자 정보 가져오기
      var userInfo = await userService.getUserInfo(currentUser!.uid);
      if (userInfo != null) {
        int level = userInfo['level'];
        int currentExp = userInfo['currentExp'];
        int maxExp = userInfo['maxExp'];

        // 경험치 추가 및 레벨 업 체크
        currentExp += dailyTasks[index].xp;

        // 경험치가 maxExp를 초과하면 레벨 업
        if (currentExp >= maxExp) {
          level += 1;
          currentExp -= maxExp; // 초과 경험치는 다음 레벨로 이월
          maxExp = (maxExp * 1.2).round(); // 다음 레벨업에 필요한 경험치 증가 (20% 증가)
        }

        // Firestore에 사용자 정보 업데이트
        await userService.updateUserLevelAndExp(
          currentUser!.uid,
          level,
          currentExp,
          maxExp,
        );

        if (kDebugMode) {
          print(
              'Task Completed: ${dailyTasks[index].name}, XP Earned: ${dailyTasks[index].xp}');
          print('Updated Level: $level, Current Exp: $currentExp');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일일 과제')),
      body: ListView.builder(
        itemCount: dailyTasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(dailyTasks[index].name),
            trailing: Checkbox(
              value: dailyTasks[index].isCompleted,
              onChanged: (bool? value) {
                completeTask(index);
              },
            ),
          );
        },
      ),
    );
  }
}

class Task {
  String name;
  bool isCompleted;
  int xp;

  Task({required this.name, required this.isCompleted, required this.xp});
}
