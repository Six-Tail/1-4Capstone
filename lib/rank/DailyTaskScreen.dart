import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../Router.dart';
import '../service/User_Service.dart';
import 'model/daily_task_model.dart';
import 'model/weekly_task_model.dart';

class DailyTasksPage extends StatefulWidget {
  const DailyTasksPage({super.key});

  @override
  _DailyTasksPageState createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends State<DailyTasksPage> with WidgetsBindingObserver {
  late Timer timer;
  final UserService userService = UserService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<double>? _achievementProgressFuture;
  Future<int>? _totalEventsCountFuture; // 새로운 Future 변수 선언
  Future<int>? _completedEventsCountFuture;
  int totalRegisteredEvents = 0;
  int totalCompletedEvents = 0;
  DateTime? lastClaimedTime;
  Duration timeUntilReset = Duration.zero;

  List<DailyTask> dailyTasks = [
    DailyTask(name: '일일 출석하기', isCompleted: false, xp: 30, hasClaimedXP: false),
    DailyTask(name: '일정 3개 등록하기', isCompleted: false, xp: 50, hasClaimedXP: false),
    DailyTask(name: '일정 3개 완료하기', isCompleted: false, xp: 80, hasClaimedXP: false),
    DailyTask(name: '달성률 80% 이상 달성하기', isCompleted: false, xp: 100, hasClaimedXP: false),
  ];

  // 전역변수로 weeklyTasks를 정의
  List<WeeklyTask> weeklyTasks = [
    WeeklyTask(name: '5일 출석하기', isCompleted: false, xp: 150, hasClaimedXP: false, currentAttendance: 0),
    WeeklyTask(name: '일정 15개 등록하기', isCompleted: false, xp: 300, hasClaimedXP: false),
    WeeklyTask(name: '일정 15개 완료하기', isCompleted: false, xp: 600, hasClaimedXP: false),
    WeeklyTask(name: '달성률 100% 달성하기', isCompleted: false, xp: 800, hasClaimedXP: false),
  ];

// completeDailyAttendanceTask 함수 내에서 사용
  Future<void> completeDailyAttendanceTask() async {
    if (currentUser != null) {
      // 일일 과제의 상태를 Firestore에서 가져옵니다.
      var taskStatus = await userService.getDailyTaskStatus(currentUser!.uid, dailyTasks[0].name);

      // 이전에 경험치를 획득하지 않은 경우에만 실행합니다.
      if (taskStatus == null || !(taskStatus['hasClaimedXP'] ?? false)) {
        dailyTasks[0].isCompleted = true;
        dailyTasks[0].hasClaimedXP = false;

        // 주간 미션 '5일 출석하기' 과제를 weeklyTasks에서 찾습니다.
        var weeklyTask = weeklyTasks.firstWhere((task) => task.name == '5일 출석하기');

        // 주간 출석 상태를 Firestore에서 최신 상태로 가져와 업데이트합니다.
        var weeklyTaskStatus = await userService.getWeeklyTaskStatus(currentUser!.uid, weeklyTask.name);
        if (weeklyTaskStatus != null) {
          weeklyTask.currentAttendance = weeklyTaskStatus['currentAttendance'] ?? 0;
        }

        // 출석 횟수를 증가시킨 후 Firestore에 업데이트합니다.
        weeklyTask.currentAttendance++;

        // 일일 출석 미션 상태를 Firestore에 업데이트
        await userService.updateDailyTaskStatus(
          currentUser!.uid,
          dailyTasks[0].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
        );

        // 주간 미션 '5일 출석하기'의 출석 횟수를 Firestore에 업데이트
        await userService.updateWeeklyTaskStatus(
          currentUser!.uid,
          weeklyTask.name,
          null,
          isCompleted: false,
          hasClaimedXP: false,
          currentAttendance: weeklyTask.currentAttendance, // 증가된 출석 횟수를 Firestore에 저장
        );

        if (kDebugMode) {
          print('currentAttendance: ${weeklyTask.currentAttendance}');
        }
      }
    }
  }
  /* 전 코드
  Future<void> completeDailyAttendanceTask() async {
    if (currentUser != null) {
      var taskStatus = await userService.getDailyTaskStatus(currentUser!.uid, dailyTasks[0].name);

      if (taskStatus == null || !(taskStatus['hasClaimedXP'] ?? false)) {
        dailyTasks[0].isCompleted = true;
        dailyTasks[0].hasClaimedXP = false;

        // 주간 미션의 currentAttendance 값을 증가
        var weeklyTask = weeklyTasks.firstWhere((task) => task.name == '5일 출석하기');
        weeklyTask.currentAttendance++;

        await userService.updateDailyTaskStatus(
          currentUser!.uid,
          dailyTasks[0].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
        );

        await userService.updateWeeklyTaskStatus(
          currentUser!.uid,
          weeklyTask.name,
          null,
          isCompleted: false,
          hasClaimedXP: false,
          currentAttendance: weeklyTask.currentAttendance, // 이 값을 Firebase에 저장해야 합니다.
        );

        if (kDebugMode) {
          print('currentAttendance: ${weeklyTask.currentAttendance}');
        }
      }
    }
  }
  */


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 앱 라이프사이클 감지 시작
    _calculateTimeUntilReset();
    _startTimer();
    loadTasks();
    _achievementProgressFuture = _calculateAchievementProgress();
    _totalEventsCountFuture = _getTotalEventsCount();
    _completedEventsCountFuture = _getCompletedEventsCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 앱 라이프사이클 감지 해제
    timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 돌아올 때 자정이 지났는지 확인
      _checkAndResetMissionsIfNeeded();
    }
  }

  void _checkAndResetMissionsIfNeeded() {
    final now = DateTime.now();
    final lastReset = lastClaimedTime ?? DateTime(now.year, now.month, now.day);
    final nextReset = DateTime(lastReset.year, lastReset.month, lastReset.day + 1);

    if (now.isAfter(nextReset)) {
      lastClaimedTime = null; // 자정이 지나면 lastClaimedTime 초기화
      for (var task in dailyTasks) {
        task.hasClaimedXP = false;
        task.isCompleted = false;
      }
      _resetDailyMetrics();
      _calculateTimeUntilReset(); // 새 자정 시간 계산
    }
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _calculateTimeUntilReset();
        if (timeUntilReset.isNegative) {
          _checkAndResetMissionsIfNeeded();
        }
      });
    });
  }

  void _calculateTimeUntilReset() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    timeUntilReset = nextMidnight.difference(now);
  }

  Future<void> _resetDailyMetrics() async {
    if (currentUser == null) return;
    try {
      await firestore.collection('users').doc(currentUser!.uid).collection('daily_reset').doc('event_count')
          .set({
        'totalEventsCount': 0, // 등록된 일정 수 초기화
        'completeEventsCount': 0, // 완료된 일정 수 초기화
        'achievementRate': 0.0, // 달성률 초기화
      }, SetOptions(merge: true)); // merge: true 옵션 추가
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting daily metrics in users/daily_reset collection: $e');
      }
    }
  }

  Future<double> _calculateAchievementProgress() async {
    // 사용자 이벤트 수를 가져와서 진행률 계산
    final userEventsSnapshot = await firestore.collection('events').where('uid', isEqualTo: currentUser!.uid).get();

    int totalEvents = userEventsSnapshot.docs.length;
    int completedEvents = userEventsSnapshot.docs.where((doc) => doc.data()['isCompleted'] == true).length;

    // 완료 비율을 계산
    if (totalEvents > 0) {
      double achievementRate = completedEvents / totalEvents;

      // 80% 이상이면 1.0을 반환하고, 그 이하의 비율을 0.8로 나누어 조정
      if (achievementRate >= 0.8) {
        return 1.0; // 80% 이상인 경우
      } else {
        return achievementRate / 0.8; // 80% 이하인 경우 비율 조정
      }
    } else {
      return 0.0; // 이벤트가 없으면 0으로 설정
    }
  }

  Future<int> _getTotalEventsCount() async {
    final userEventsSnapshot = await firestore.collection('events').where('uid', isEqualTo: currentUser!.uid).get();
    return userEventsSnapshot.docs.length;
  }

  Future<int> _getCompletedEventsCount() async {
    final userEventsSnapshot = await firestore.collection('events').where('uid', isEqualTo: currentUser!.uid).where('isCompleted', isEqualTo: true).get();
    return userEventsSnapshot.docs.length;
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
                double progressValue;

                if (dailyTasks[index].name == '달성률 80% 이상 달성하기') {
                  return FutureBuilder<double>( // Achievement progress
                    future: _achievementProgressFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('오류 발생'));
                      } else {
                        progressValue = snapshot.data ?? 0.0;
                        return _buildTaskItem(
                            dailyTasks[index], progressValue, index);
                      }
                    },
                  );
                } else {
                  progressValue = dailyTasks[index].isCompleted ? 1.0 : 0.0;
                }

                if (dailyTasks[index].name == '일정 3개 등록하기') {
                  return FutureBuilder<int>( // Total events count
                    future: _totalEventsCountFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('오류 발생'));
                      } else {
                        int totalEvents = snapshot.data ?? 0;
                        // Calculate progress based on total events
                        progressValue = totalEvents / 3.0; // Normalize to a value between 0.0 and 1.0
                        return _buildTaskItem(dailyTasks[index], progressValue,
                            index, totalEvents);
                      }
                    },
                  );
                }

                if (dailyTasks[index].name == '일정 3개 완료하기') {
                  return FutureBuilder<int>( // Completed events count
                    future: _completedEventsCountFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('오류 발생'));
                      } else {
                        int totalCompletedEvents =
                            snapshot.data ?? 0; // 완료된 이벤트 수
                        // Calculate progress based on completed events
                        progressValue = totalCompletedEvents / 3.0; // Normalize to a value between 0.0 and 1.0
                        return _buildTaskItem(dailyTasks[index], progressValue,
                            index, null, totalCompletedEvents);
                      }
                    },
                  );
                }

                return _buildTaskItem(dailyTasks[index], progressValue, index);
              },
            ),
          ),
        ],
      ),
    );
  }

// 태스크 항목을 빌드하는 메소드
  Widget _buildTaskItem(DailyTask task, double progressValue, int index,
      [int? totalEvents, int? totalCompletedEvents]) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: task.isCompleted ? Colors.grey[300] : Colors.grey[800],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    if (task.name == '달성률 80% 이상 달성하기') // 달성률 표시
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
                              '(${(achievementRate * 80).toStringAsFixed(0)}%/80%)',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 10,
                              ),
                            );
                          }
                        },
                      ),
                    if (task.name == '일정 3개 등록하기' && totalEvents != null)
                      Text(
                        '($totalEvents/3)',
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 10,
                        ),
                      ),
                    if (task.name == '일정 3개 완료하기' &&
                        totalCompletedEvents != null)
                      Text(
                        '($totalCompletedEvents/3)',
                        style: const TextStyle(
                          color: Colors.amberAccent,
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
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progressValue, // Progress based on the task completion
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
          task.isCompleted
              ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              task.hasClaimedXP ? Colors.grey : Colors.amber,
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 16),
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
              backgroundColor: task.isCompleted
                  ? Colors.grey
                  : Colors.lightBlueAccent,
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              Get.to(() => RouterPage());
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
    for (int i = 0; i < dailyTasks.length; i++) {
      var taskStatus = await userService.getDailyTaskStatus(currentUser!.uid, dailyTasks[i].name);
      if (taskStatus != null) {
        dailyTasks[i].hasClaimedXP = taskStatus['hasClaimedXP'] ?? false;
        dailyTasks[i].lastClaimedTime = taskStatus['lastClaimedTime']?.toDate();
        dailyTasks[i].isCompleted = taskStatus['isCompleted'] ?? false;
      } else {
        dailyTasks[i].hasClaimedXP = false;
        dailyTasks[i].isCompleted = false;
        dailyTasks[i].lastClaimedTime = null;
      }
    }
    await completeDailyAttendanceTask(); // 페이지가 열릴 때 일일 출석하기 미션 자동 완료
    await addDailyTasksToFirestore();
    await Future.wait([checkTaskForThreeEvents(), checkTaskForThreeCompletedEvents(), checkTaskAchievement(),
    ]);
    setState(() {}); // 모든 작업이 완료된 후 UI 업데이트
  }

  Future<void> _updateTotalEventsCountInUsersDailyReset(int totalEvents) async {
    if (currentUser == null) return;
    try {
      await firestore.collection('users').doc(currentUser!.uid).collection('daily_reset').doc('event_count')
          .set({
        'totalEventsCount': totalEvents, // 등록된 일정 수를 'totalEventsCount' 필드에 저장
      }, SetOptions(merge: true)); // merge: true 옵션 추가
    } catch (e) {
      if (kDebugMode) {
        print('Error updating total events count in users/daily_reset collection: $e');
      }
    }
  }

  Future<void> _updateCompletedEventsCountInUsersDailyReset(int completedEvents) async {
    if (currentUser == null) return;
    try {
      await firestore.collection('users').doc(currentUser!.uid).collection('daily_reset').doc('event_count')
          .set({
        'completeEventsCount': completedEvents, // 등록된 일정 수를 'completeEventsCount' 필드에 저장
      }, SetOptions(merge: true)); // merge: true 옵션 추가
    } catch (e) {
      if (kDebugMode) {
        print('Error updating complete events count in users/daily_reset collection: $e');
      }
    }
  }

  Future<void> _updateAchievementRateInUsersDailyReset(double achievementRate) async {
    if (currentUser == null) return;
    try {
      await firestore.collection('users').doc(currentUser!.uid).collection('daily_reset').doc('event_count')
          .set({
        'achievementRate': achievementRate, // 달성률을 'achievementRate' 필드에 저장
      }, SetOptions(merge: true)); // merge: true 옵션 추가
    } catch (e) {
      if (kDebugMode) {
        print('Error updating achievement rate in users/daily_reset collection: $e');
      }
    }
  }

// "일정 3개 등록하기" 미션 확인 및 업데이트 메소드
  Future<void> checkTaskForThreeEvents() async {
    final userEventsSnapshot = await firestore.collection('events').where('uid', isEqualTo: currentUser!.uid).get();
    int totalEvents = userEventsSnapshot.docs.length;
    totalRegisteredEvents = totalEvents; // 등록된 일정 개수 상태 설정
    // Firebase에 일정 수를 저장하는 메소드 호출
    await _updateTotalEventsCountInUsersDailyReset(totalEvents);

    var taskIndex = dailyTasks.indexWhere((task) => task.name == '일정 3개 등록하기');
    // "일정 3개 등록하기" 미션 확인 및 업데이트
    if (totalEvents >= 3) {
      if (!dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = true; // 미션 완료로 설정
        await userService.updateDailyTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
        );
      }
    } else {
      if (dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = false; // 미션 미완료로 설정
        await userService.updateDailyTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
          null,
          isCompleted: false,
          hasClaimedXP: false,
        );
      }
    }
  }

// "일정 3개 완료하기" 미션 확인 및 업데이트 메소드
  Future<void> checkTaskForThreeCompletedEvents() async {
    final userEventsSnapshot = await firestore.collection('events').where('uid', isEqualTo: currentUser!.uid).where('isCompleted', isEqualTo: true).get();
    int completedEvents = userEventsSnapshot.docs.length;
    totalCompletedEvents = completedEvents;

    // Firebase에 완료된 일정 수를 저장하는 메소드 호출
    await _updateCompletedEventsCountInUsersDailyReset(completedEvents);

    var taskIndex = dailyTasks.indexWhere((task) => task.name == '일정 3개 완료하기');
    // "일정 3개 완료하기" 미션 확인 및 업데이트
    if (completedEvents >= 3) {
      if (!dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = true; // 미션 완료로 설정
        await userService.updateDailyTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
        );
      }
    } else {
      if (dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = false; // 미션 미완료로 설정
        await userService.updateDailyTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
          null,
          isCompleted: false,
          hasClaimedXP: false,
        );
      }
    }
  }

  Future<void> checkTaskAchievement() async {
    final userEventsSnapshot = await firestore.collection('events').where('uid', isEqualTo: currentUser!.uid).get();
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
      await _updateAchievementRateInUsersDailyReset(achievementRate);
    }

    // "일정 달성률 80% 이상 달성하기" 태스크 확인 및 업데이트
    var taskIndex = dailyTasks.indexWhere((task) => task.name == '달성률 80% 이상 달성하기');
    if (achievementRate >= 0.8) {
      if (!dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = true; // 미션을 완료로 설정
        // Firestore에 업데이트하여 데이터를 동기화
        await userService.updateDailyTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
        );
      }
    } else {
      if (dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = false; // 미션을 미완료로 설정
        // Firestore에 업데이트하여 데이터를 동기화
        await userService.updateDailyTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
          null,
          isCompleted: false,
          hasClaimedXP: false,
        );
      }
    }
  }


  void completeTask(int index) async {
    setState(() {
      // UI에서 태스크 완료 상태 업데이트
      dailyTasks[index].isCompleted = true;
    });
    // Firestore에 태스크 완료 상태 저장
    if (currentUser != null) {
      await userService.updateDailyTaskStatus(
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
      await userService.updateDailyTaskStatus(
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

  Future<void> addDailyTasksToFirestore() async {
    for (var task in dailyTasks) {
      // Firestore에 태스크가 없는 경우에만 추가
      var taskStatus =
          await userService.getDailyTaskStatus(currentUser!.uid, task.name);
      if (taskStatus == null) {
        await userService.updateDailyTaskStatus(
          currentUser!.uid,
          task.name,
          null, // lastClaimedTime 초기화
          isCompleted: false, // 초기 상태는 완료되지 않음
          hasClaimedXP: false, // 초기 상태는 XP 청구 안 함
        );
      }
    }
  }
}
