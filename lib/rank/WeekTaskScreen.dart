import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Router.dart';
import '../service/User_Service.dart';
import 'model/weekly_task_model.dart';

class WeeklyTasksPage extends StatefulWidget {
  const WeeklyTasksPage({super.key});

  @override
  _WeeklyTasksPageState createState() => _WeeklyTasksPageState();
}

class _WeeklyTasksPageState extends State<WeeklyTasksPage> {
  final UserService userService = UserService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<double>? _achievementProgressFuture;
  Future<int>? _totalEventsCountFuture;
  Future<int>? _completedEventsCountFuture;
  int totalRegisteredEvents = 0;
  int totalCompletedEvents = 0;

  List<WeeklyTask> weeklyTasks = [
    WeeklyTask(
        name: '5일 출석하기',
        isCompleted: false,
        xp: 150,
        hasClaimedXP: false,
        currentAttendance: 0),
    WeeklyTask(
        name: '일정 15개 등록하기', isCompleted: false, xp: 300, hasClaimedXP: false),
    WeeklyTask(
        name: '일정 15개 완료하기', isCompleted: false, xp: 600, hasClaimedXP: false),
    WeeklyTask(
        name: '달성률 100% 달성하기',
        isCompleted: false,
        xp: 800,
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
    loadTasks();

    _achievementProgressFuture = _calculateAchievementProgress();
    _totalEventsCountFuture = _getTotalEventsCount();
    _completedEventsCountFuture = _getCompletedEventsCount();
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
          lastClaimedTime = null;

          for (var task in weeklyTasks) {
            task.hasClaimedXP = false;
            task.isCompleted = false;
          }

          _resetWeeklyMetrics();
        }
      });
    });
  }

  void _calculateTimeUntilReset() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;

    DateTime nextMonday;
    if (currentWeekday == DateTime.monday) {
      nextMonday = DateTime(now.year, now.month, now.day + 7);
    } else {
      nextMonday =
          DateTime(now.year, now.month, now.day + (8 - currentWeekday));
    }

    nextMonday =
        DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 0, 0, 0);
    timeUntilReset = nextMonday.difference(now);
  }

  Future<void> _resetWeeklyMetrics() async {
    if (currentUser == null) return;
    try {
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('weekly_reset')
          .doc('event_count')
          .set({
        'totalEventsCount': 0,
        'completeEventsCount': 0,
        'achievementRate': 0.0,
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print(
            'Error resetting weekly metrics in users/weekly_reset collection: $e');
      }
    }
  }

  Future<double> _calculateAchievementProgress() async {
    final userEventsSnapshot = await firestore
        .collection('events')
        .where('uid', isEqualTo: currentUser!.uid)
        .get();

    int totalEvents = userEventsSnapshot.docs.length;
    int completedEvents = userEventsSnapshot.docs
        .where((doc) => doc.data()['isCompleted'] == true)
        .length;

    if (totalEvents > 0) {
      double achievementRate = completedEvents / totalEvents;
      return achievementRate >= 1.0 ? 1.0 : achievementRate / 1.0;
    } else {
      return 0.0;
    }
  }

  Future<int> _getTotalEventsCount() async {
    final userEventsSnapshot = await firestore
        .collection('events')
        .where('uid', isEqualTo: currentUser!.uid)
        .get();
    return userEventsSnapshot.docs.length;
  }

  Future<int> _getCompletedEventsCount() async {
    final userEventsSnapshot = await firestore
        .collection('events')
        .where('uid', isEqualTo: currentUser!.uid)
        .where('isCompleted', isEqualTo: true)
        .get();
    return userEventsSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(scrolledUnderElevation: 0, title: const Text('주간 미션')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '남은 시간: ${timeUntilReset.inDays}일 ${timeUntilReset.inHours.remainder(24)}시간 ${timeUntilReset.inMinutes.remainder(60)}분 ${timeUntilReset.inSeconds.remainder(60)}초',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: weeklyTasks.length,
              itemBuilder: (context, index) {
                double progressValue;

                if (weeklyTasks[index].name == '달성률 100% 달성하기') {
                  return FutureBuilder<double>(
                    future: _achievementProgressFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('오류 발생'));
                      } else {
                        progressValue = snapshot.data ?? 0.0;
                        return _buildTaskItem(
                            weeklyTasks[index], progressValue, index);
                      }
                    },
                  );
                } else {
                  progressValue = weeklyTasks[index].isCompleted ? 1.0 : 0.0;
                }

                if (weeklyTasks[index].name == '일정 15개 등록하기') {
                  return FutureBuilder<int>(
                    future: _totalEventsCountFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('오류 발생'));
                      } else {
                        int totalEvents = snapshot.data ?? 0;
                        progressValue = totalEvents / 15.0;
                        return _buildTaskItem(weeklyTasks[index], progressValue,
                            index, totalEvents);
                      }
                    },
                  );
                }

                if (weeklyTasks[index].name == '일정 15개 완료하기') {
                  return FutureBuilder<int>(
                    future: _completedEventsCountFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('오류 발생'));
                      } else {
                        int totalCompletedEvents = snapshot.data ?? 0;
                        progressValue = totalCompletedEvents / 15.0;
                        return _buildTaskItem(weeklyTasks[index], progressValue,
                            index, null, totalCompletedEvents);
                      }
                    },
                  );
                }

                return _buildTaskItem(weeklyTasks[index], progressValue, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(WeeklyTask task, double progressValue, int index,
      [int? totalEvents, int? totalCompletedEvents]) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: task.isCompleted ? Colors.grey[300] : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: task.isCompleted ? Colors.black : Colors.white,
                      ),
                    ),
                    if (task.name == '5일 출석하기')
                      Text(
                        '(${task.currentAttendance}/5)',
                        style: TextStyle(
                          color: task.isCompleted ? const Color(0xff4496de) : Colors.amberAccent,
                          fontSize: 10,
                        ),
                      ),
                    if (task.name == '달성률 100% 달성하기') // 달성률 표시
                      FutureBuilder<double>(
                        future: _achievementProgressFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text(
                              '오류 발생',
                              style: TextStyle(color: Colors.white),
                            );
                          } else {
                            double achievementRate = snapshot.data ?? 0.0;
                            return Text(
                              '(${(achievementRate * 100).toStringAsFixed(0)}%/100%)',
                              style: TextStyle(
                                color: task.isCompleted ? const Color(0xff4496de) : Colors.amberAccent,
                                fontSize: 10,
                              ),
                            );
                          }
                        },
                      ),
                    if (task.name == '일정 15개 등록하기' && totalEvents != null)
                      Text(
                        '($totalEvents/15)',
                        style: TextStyle(
                          color: task.isCompleted ? const Color(0xff4496de) : Colors.amberAccent,
                          fontSize: 10,
                        ),
                      ),
                    if (task.name == '일정 15개 완료하기' &&
                        totalCompletedEvents != null)
                      Text(
                        '($totalCompletedEvents/15)',
                        style: TextStyle(
                          color: task.isCompleted ? const Color(0xff4496de) : Colors.amberAccent,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${task.xp} EXP',
                      style: TextStyle(
                        color: task.isCompleted ? const Color(0xff4496de) : Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: task.name == '5일 출석하기'
                            ? task.currentAttendance / 5.0
                            : progressValue,
                        backgroundColor: Colors.grey,
                        color: task.isCompleted ? const Color(0xff4496de) : Colors.amberAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          task.isCompleted
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        task.hasClaimedXP ? Colors.grey : Colors.amber,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: task.hasClaimedXP ? null : () => claimXP(index),
                  child: const Text(
                    'EXP 획득',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        task.isCompleted ? Colors.grey : Colors.lightBlueAccent,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const RouterPage());
                  },
                  child: const Text('이동 하기'),
                ),
        ],
      ),
    );
  }

  Future<void> loadTasks() async {
    if (currentUser == null) return;
    totalRegisteredEvents = await _getTotalEventsCount(); // 일정 수를 미리 불러옴
    for (int i = 0; i < weeklyTasks.length; i++) {
      var taskStatus = await userService.getWeeklyTaskStatus(
          currentUser!.uid, weeklyTasks[i].name);

      if (taskStatus != null) {
        weeklyTasks[i].hasClaimedXP = taskStatus['hasClaimedXP'] ?? false;
        weeklyTasks[i].lastClaimedTime =
            taskStatus['lastClaimedTime']?.toDate();
        weeklyTasks[i].isCompleted = taskStatus['isCompleted'] ?? false;

        // "5일 출석하기" 과제의 currentAttendance를 불러와 업데이트
        if (weeklyTasks[i].name == '5일 출석하기') {
          weeklyTasks[i].currentAttendance =
              taskStatus['currentAttendance'] ?? 0;

          // 출석 횟수가 5에 도달했는지 확인하고, 미션을 완료 처리
          if (weeklyTasks[i].currentAttendance >= 5) {
            weeklyTasks[i].isCompleted =
                true; // isCompleted를 true로 설정하여 경험치 획득 가능

            // Firestore에 상태 업데이트
            await userService.updateWeeklyTaskStatus(
              currentUser!.uid,
              weeklyTasks[i].name,
              weeklyTasks[i].lastClaimedTime,
              isCompleted: weeklyTasks[i].isCompleted,
              hasClaimedXP: weeklyTasks[i].hasClaimedXP,
              currentAttendance: weeklyTasks[i].currentAttendance,
            );
          }
        }
      } else {
        // Firestore에 데이터가 없는 경우 기본값 설정
        weeklyTasks[i].hasClaimedXP = false;
        weeklyTasks[i].isCompleted = false;
        weeklyTasks[i].lastClaimedTime = null;
        weeklyTasks[i].currentAttendance = 0;
      }
    }

    await addDailyTasksToFirestore();
    await Future.wait([
      checkTaskForFiftyEvents(),
      checkTaskForThreeCompletedEvents(),
      checkTaskAchievement()
    ]);
    setState(() {}); // 모든 작업이 완료된 후 UI 업데이트
  }

  Future<void> _updateTotalEventsCountInUsersWeeklyReset(
      int totalEvents) async {
    if (currentUser == null) return;
    try {
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('weekly_reset')
          .doc('event_count')
          .set({
        'totalEventsCount': totalEvents, // 등록된 일정 수를 'totalEventsCount' 필드에 저장
      }, SetOptions(merge: true)); // merge: true 옵션 추가
    } catch (e) {
      if (kDebugMode) {
        print(
            'Error updating total events count in users/weekly_reset collection: $e');
      }
    }
  }

  Future<void> _updateCompletedEventsCountInUsersWeeklyReset(
      int completedEvents) async {
    if (currentUser == null) return;
    try {
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('weekly_reset')
          .doc('event_count')
          .set({
        'completeEventsCount': completedEvents,
        // 등록된 일정 수를 'completeEventsCount' 필드에 저장
      }, SetOptions(merge: true)); // merge: true 옵션 추가
    } catch (e) {
      if (kDebugMode) {
        print(
            'Error updating complete events count in users/weekly_reset collection: $e');
      }
    }
  }

  Future<void> _updateAchievementRateInUsersWeeklyReset(
      double achievementRate) async {
    if (currentUser == null) return;
    try {
      await firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('weekly_reset')
          .doc('event_count')
          .set({
        'achievementRate': achievementRate, // 달성률을 'achievementRate' 필드에 저장
      }, SetOptions(merge: true)); // merge: true 옵션 추가
    } catch (e) {
      if (kDebugMode) {
        print(
            'Error updating achievement rate in users/daily_reset collection: $e');
      }
    }
  }

// "일정 15개 등록하기" 미션 확인 및 업데이트 메소드
  Future<void> checkTaskForFiftyEvents() async {
    final userEventsSnapshot = await firestore
        .collection('events')
        .where('uid', isEqualTo: currentUser!.uid)
        .get();
    int totalEvents = userEventsSnapshot.docs.length;
    totalRegisteredEvents = totalEvents; // 등록된 일정 개수 상태 설정
    // Firebase에 일정 수를 저장하는 메소드 호출
    await _updateTotalEventsCountInUsersWeeklyReset(totalEvents);

    var taskIndex =
        weeklyTasks.indexWhere((task) => task.name == '일정 15개 등록하기');
    // "일정 15개 등록하기" 미션 확인 및 업데이트
    if (totalEvents >= 15) {
      if (!weeklyTasks[taskIndex].isCompleted) {
        weeklyTasks[taskIndex].isCompleted = true; // 미션 완료로 설정
        await userService.updateWeeklyTaskStatus(
          currentUser!.uid,
          weeklyTasks[taskIndex].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
          currentAttendance: 0,
        );
      }
    } else {
      if (weeklyTasks[taskIndex].isCompleted) {
        weeklyTasks[taskIndex].isCompleted = false; // 미션 미완료로 설정
        await userService.updateWeeklyTaskStatus(
          currentUser!.uid,
          weeklyTasks[taskIndex].name,
          null,
          isCompleted: false,
          hasClaimedXP: false,
          currentAttendance: 0,
        );
      }
    }
  }

// "일정 15개 완료하기" 미션 확인 및 업데이트 메소드
  Future<void> checkTaskForThreeCompletedEvents() async {
    final userEventsSnapshot = await firestore
        .collection('events')
        .where('uid', isEqualTo: currentUser!.uid)
        .where('isCompleted', isEqualTo: true)
        .get();
    int completedEvents = userEventsSnapshot.docs.length;
    totalCompletedEvents = completedEvents;

    // Firebase에 완료된 일정 수를 저장하는 메소드 호출
    await _updateCompletedEventsCountInUsersWeeklyReset(completedEvents);

    var taskIndex =
        weeklyTasks.indexWhere((task) => task.name == '일정 15개 완료하기');
    // "일정 15개 완료하기" 미션 확인 및 업데이트
    if (completedEvents >= 15) {
      if (!weeklyTasks[taskIndex].isCompleted) {
        weeklyTasks[taskIndex].isCompleted = true; // 미션 완료로 설정
        await userService.updateWeeklyTaskStatus(
          currentUser!.uid,
          weeklyTasks[taskIndex].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
          currentAttendance: 0,
        );
      }
    } else {
      if (weeklyTasks[taskIndex].isCompleted) {
        weeklyTasks[taskIndex].isCompleted = false; // 미션 미완료로 설정
        await userService.updateWeeklyTaskStatus(
          currentUser!.uid,
          weeklyTasks[taskIndex].name,
          null,
          isCompleted: false,
          hasClaimedXP: false,
          currentAttendance: 0,
        );
      }
    }
  }

  Future<void> checkTaskAchievement() async {
    final userEventsSnapshot = await firestore
        .collection('events')
        .where('uid', isEqualTo: currentUser!.uid)
        .get();
    int totalEvents = userEventsSnapshot.docs.length;
    int completedEvents = 0;

    // 완료된 이벤트 수 계산
    for (var eventDoc in userEventsSnapshot.docs) {
      if (eventDoc.data()['isCompleted'] == true) {
        completedEvents++;
      }
    }

    double achievementRate = 0.0;
    if (totalEvents > 0) {
      achievementRate = completedEvents / totalEvents;
      // Firestore에 달성률 저장
      await _updateAchievementRateInUsersWeeklyReset(achievementRate);
    }

    // "일정 달성률 100% 이상 달성하기" 태스크 확인 및 업데이트
    var taskIndex =
        weeklyTasks.indexWhere((task) => task.name == '달성률 100% 달성하기');
    if (achievementRate >= 1.0) {
      if (!weeklyTasks[taskIndex].isCompleted) {
        weeklyTasks[taskIndex].isCompleted = true; // 미션을 완료로 설정
        // Firestore에 업데이트하여 데이터를 동기화
        await userService.updateWeeklyTaskStatus(
          currentUser!.uid,
          weeklyTasks[taskIndex].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
          currentAttendance: 0,
        );
      }
    } else {
      if (weeklyTasks[taskIndex].isCompleted) {
        weeklyTasks[taskIndex].isCompleted = false; // 미션을 미완료로 설정
        // Firestore에 업데이트하여 데이터를 동기화
        await userService.updateWeeklyTaskStatus(
          currentUser!.uid,
          weeklyTasks[taskIndex].name,
          null,
          isCompleted: false,
          hasClaimedXP: false,
          currentAttendance: 0,
        );
      }
    }
  }

  void completeTask(int index) async {
    setState(() {
      // UI에서 태스크 완료 상태 업데이트
      weeklyTasks[index].isCompleted = true;
    });
    // Firestore에 태스크 완료 상태 저장
    if (currentUser != null) {
      await userService.updateWeeklyTaskStatus(
        currentUser!.uid,
        weeklyTasks[index].name,
        null,
        isCompleted: true, // isCompleted를 true로 설정
        hasClaimedXP: false, // 획득 여부는 초기화하여 획득 가능 상태로 유지
        currentAttendance: 0,
      );
      // 로컬 리스트에서도 상태 업데이트
      weeklyTasks[index].isCompleted = true; // 로컬 리스트에서도 isCompleted 업데이트
      weeklyTasks[index].hasClaimedXP = false; // 획득 상태 초기화
    }
  }

  void claimXP(int index) async {
    final currentTime = DateTime.now();
    // 해당 태스크가 이미 완료되었는지 확인
    if (!weeklyTasks[index].isCompleted) {
      return; // 태스크가 완료되지 않았다면 경험치 청구를 중단
    }
    // 하루에 한 번만 경험치를 받을 수 있도록 하는 조건 체크
    if (weeklyTasks[index].lastClaimedTime != null &&
        weeklyTasks[index].lastClaimedTime!.day == currentTime.day &&
        weeklyTasks[index].lastClaimedTime!.year == currentTime.year &&
        weeklyTasks[index].lastClaimedTime!.month == currentTime.month) {
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
      currentExp += weeklyTasks[index].xp;
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
      await userService.updateWeeklyTaskStatus(
        currentUser!.uid,
        weeklyTasks[index].name,
        currentTime,
        isCompleted: true, // 태스크는 이미 완료된 상태이므로 true로 유지
        hasClaimedXP: true, // 경험치를 청구했으므로 hasClaimedXP를 true로 설정
        currentAttendance:
            weeklyTasks[index].currentAttendance, // 현재 currentAttendance 값 유지
      );
      // 콘솔에 경험치 획득 로그 출력
      if (kDebugMode) {
        print('사용자 ID: ${currentUser!.uid}');
        print('미션 이름: ${weeklyTasks[index].name}');
        print('획득한 경험치: ${weeklyTasks[index].xp}');
        print('현재 레벨: $level');
        print('현재 경험치: $currentExp');
        print('다음 레벨까지 필요한 경험치: $maxExp');
        print('타임스탬프: $currentTime');
      }
      setState(() {
        weeklyTasks[index].lastClaimedTime = currentTime; // 경험치 획득 시간 업데이트
        weeklyTasks[index].hasClaimedXP = true; // 해당 미션의 획득 상태 업데이트
      });
    }
  }

  Future<void> addDailyTasksToFirestore() async {
    for (var task in weeklyTasks) {
      // Firestore에 태스크가 없는 경우에만 추가
      var taskStatus =
          await userService.getWeeklyTaskStatus(currentUser!.uid, task.name);
      if (taskStatus == null) {
        await userService.updateWeeklyTaskStatus(
          currentUser!.uid,
          task.name,
          null, // lastClaimedTime 초기화
          isCompleted: false, // 초기 상태는 완료되지 않음
          hasClaimedXP: false, // 초기 상태는 XP 청구 안 함
          currentAttendance: 0,
        );
      }
    }
  }
}
