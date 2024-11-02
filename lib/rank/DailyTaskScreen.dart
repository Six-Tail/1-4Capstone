import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/User_Service.dart';

class DailyTasksPage extends StatefulWidget {
  const DailyTasksPage({super.key});

  @override
  _DailyTasksPageState createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends State<DailyTasksPage> {
  final UserService userService = UserService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Task> dailyTasks = [
    Task(name: '일일 출석하기', isCompleted: false, xp: 10, hasClaimedXP: false),
    Task(
        name: '일정 3개 이상 등록하기', isCompleted: false, xp: 30, hasClaimedXP: false),
    Task(
        name: '일정 3개 이상 완료하기', isCompleted: false, xp: 60, hasClaimedXP: false),
    Task(
        name: '일정 달성률 80% 이상 달성하기',
        isCompleted: false,
        xp: 80,
        hasClaimedXP: false),
  ];

  DateTime? lastClaimedTime;
  late Timer timer;
  Duration timeUntilReset = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeUntilReset();
    _startTimer();
    loadTasks(); // 페이지가 열릴 때 태스크 정보를 불러옴
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _calculateTimeUntilReset();
        if (timeUntilReset.isNegative) {
          lastClaimedTime = null; // 자정이 지나면 lastClaimedTime 초기화
          for (var task in dailyTasks) {
            task.hasClaimedXP = false; // 각 미션의 획득 상태도 초기화
          }
        }
      });
    });
  }

  void _calculateTimeUntilReset() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    timeUntilReset = nextMidnight.difference(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일간 미션')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '남은 시간: ${timeUntilReset.inHours}시간 ${timeUntilReset.inMinutes.remainder(60)}분 ${timeUntilReset.inSeconds.remainder(60)}초',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dailyTasks.length,
              itemBuilder: (context, index) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: dailyTasks[index].isCompleted
                        ? Colors.grey[300]
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dailyTasks[index].name,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${dailyTasks[index].xp} XP',
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: dailyTasks[index].isCompleted
                                        ? 1.0
                                        : 0.0,
                                    backgroundColor: Colors.grey,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      dailyTasks[index].isCompleted
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: dailyTasks[index].hasClaimedXP
                                    ? Colors.grey // 해당 미션이 이미 획득된 경우 회색 버튼
                                    : Colors.amber,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(4), // 사각형으로 설정
                                ),
                              ),
                              onPressed: dailyTasks[index].hasClaimedXP
                                  ? null // 해당 미션이 이미 획득된 경우 비활성화
                                  : () => claimXP(index),
                              child: const Text(
                                '획득',
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlueAccent,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(4), // 사각형으로 설정
                                ),
                              ),
                              onPressed: () {
                                completeTask(index);
                              },
                              child: const Text('미션 완료'),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void loadTasks() async {
    if (currentUser == null) return;

    // 각 태스크에 대한 XP 청구 상태를 Firestore에서 가져옴
    for (int i = 0; i < dailyTasks.length; i++) {
      var taskStatus =
          await userService.getTaskStatus(currentUser!.uid, dailyTasks[i].name);
      if (taskStatus != null) {
        dailyTasks[i].hasClaimedXP = taskStatus['hasClaimedXP'] ?? false;
        dailyTasks[i].lastClaimedTime = taskStatus['lastClaimedTime']?.toDate();
        dailyTasks[i].isCompleted = taskStatus['isCompleted'] ?? false;

        // 태스크가 완료된 경우 hasClaimedXP 값을 업데이트
        if (dailyTasks[i].isCompleted && dailyTasks[i].hasClaimedXP) {
          dailyTasks[i].hasClaimedXP = true; // 버튼을 회색으로 설정하기 위해
        }
      } else {
        // 태스크가 Firestore에 없다면 기본값으로 초기화
        dailyTasks[i].hasClaimedXP = false;
        dailyTasks[i].isCompleted = false;
        dailyTasks[i].lastClaimedTime = null;
      }
    }
    setState(() {}); // 상태 업데이트
  }

  void completeTask(int index) async {
    setState(() {
      // UI에서 태스크 완료 상태 업데이트
      dailyTasks[index].isCompleted = true;
    });

    // Firestore에 태스크 완료 상태 저장
    if (currentUser != null) {
      await userService.updateTaskStatus(
        currentUser!.uid,
        dailyTasks[index].name,
        null,
        isCompleted: true, // isCompleted를 true로 설정
        hasClaimedXP: false, // 획득 여부는 초기화하여 획득 가능 상태로 유지
      );

      // 로컬 리스트에서도 상태 업데이트
      dailyTasks[index].isCompleted = true; // 로컬 리스트에서도 isCompleted 업데이트
      dailyTasks[index].hasClaimedXP = false; // 획득 상태 초기화
    }
  }

  void claimXP(int index) async {
    final currentTime = DateTime.now();

    // 해당 태스크가 이미 완료되었는지 확인
    if (!dailyTasks[index].isCompleted) {
      return; // 태스크가 완료되지 않았다면 경험치 청구를 중단
    }

    // 하루에 한 번만 경험치를 받을 수 있도록 하는 조건 체크
    if (dailyTasks[index].lastClaimedTime != null &&
        dailyTasks[index].lastClaimedTime!.day == currentTime.day &&
        dailyTasks[index].lastClaimedTime!.year == currentTime.year &&
        dailyTasks[index].lastClaimedTime!.month == currentTime.month) {
      return; // 이미 오늘 해당 미션에 대한 경험치를 받았음
    }

    if (currentUser == null) return;

    // 유저 정보 가져오기
    var userInfo = await userService.getUserInfo(currentUser!.uid);
    if (userInfo != null) {
      int currentExp = userInfo['currentExp'];
      int level = userInfo['level'];
      int maxExp = userInfo['maxExp'];

      // 경험치 추가
      currentExp += dailyTasks[index].xp;

      // 경험치가 maxExp를 초과하면 레벨 업
      if (currentExp >= maxExp) {
        level += 1;
        currentExp -= maxExp; // 초과 경험치는 다음 레벨로 이월
        maxExp = (maxExp * 1.05).round(); // 다음 레벨업에 필요한 경험치 증가 (5% 증가)
      }

      // Firestore에 사용자 정보 업데이트
      await userService.updateUserLevelAndExp(
        currentUser!.uid,
        level,
        currentExp,
        maxExp,
      );

      // Firestore에서 태스크의 획득 상태와 시간을 업데이트
      await userService.updateTaskStatus(
        currentUser!.uid,
        dailyTasks[index].name,
        currentTime,
        isCompleted: true, // 태스크는 이미 완료된 상태이므로 true로 유지
        hasClaimedXP: true, // 경험치를 청구했으므로 hasClaimedXP를 true로 설정
      );

      // 콘솔에 경험치 획득 로그 출력
      if (kDebugMode) {
        print('사용자 ID: ${currentUser!.uid}');
        print('미션 이름: ${dailyTasks[index].name}');
        print('획득한 경험치: ${dailyTasks[index].xp}');
        print('현재 레벨: $level');
        print('현재 경험치: $currentExp');
        print('다음 레벨까지 필요한 경험치: $maxExp');
        print('타임스탬프: $currentTime');
      }

      setState(() {
        dailyTasks[index].lastClaimedTime = currentTime; // 경험치 획득 시간 업데이트
        dailyTasks[index].hasClaimedXP = true; // 해당 미션의 획득 상태 업데이트
      });
    }
  }
}

class Task {
  String name;
  bool isCompleted;
  int xp;
  bool hasClaimedXP;
  DateTime? lastClaimedTime; // 각 미션의 마지막 경험치 획득 시간 추가

  Task({
    required this.name,
    required this.isCompleted,
    required this.xp,
    required this.hasClaimedXP,
    this.lastClaimedTime,
  });
}
