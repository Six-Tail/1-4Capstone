import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todobest_home/rank/model/daily_task_model.dart';

import '../Router.dart';
import '../service/User_Service.dart';

class ChallengePage extends StatefulWidget {
  const ChallengePage({super.key});

  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  final UserService userService = UserService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<int>? _totalEventsCountFuture;
  Future<int>? _completedEventsCountFuture;
  int totalRegisteredEvents = 0;
  int totalCompletedEvents = 0;

  List<DailyTask> dailyTasks = [
    DailyTask(
        name: '10일 출석하기',
        isCompleted: false,
        xp: 500,
        hasClaimedXP: false,
        currentAttendance: 0),
    DailyTask(
        name: '일정 50개 등록하기', isCompleted: false, xp: 1500, hasClaimedXP: false),
    DailyTask(
        name: '일정 50개 완료하기', isCompleted: false, xp: 3000, hasClaimedXP: false),
    DailyTask(
        name: '10레벨 달성하기', isCompleted: false, xp: 1000, hasClaimedXP: false),
  ];

  // 출석 일수 업데이트
  void updateAttendance() async {
    if (currentUser == null) return;

    var attendanceTaskIndex =
        dailyTasks.indexWhere((task) => task.name == '10일 출석하기');

    if (attendanceTaskIndex != -1) {
      var lastAttendanceDate = dailyTasks[attendanceTaskIndex].lastClaimedTime;
      var now = DateTime.now();

      // 마지막 출석 날짜가 오늘이 아닌 경우 출석 일수를 1 증가시킴
      if (lastAttendanceDate == null ||
          lastAttendanceDate.year != now.year ||
          lastAttendanceDate.month != now.month ||
          lastAttendanceDate.day != now.day) {
        dailyTasks[attendanceTaskIndex].currentAttendance++;
        dailyTasks[attendanceTaskIndex].lastClaimedTime = now;

        if (dailyTasks[attendanceTaskIndex].currentAttendance >= 10) {
          dailyTasks[attendanceTaskIndex].isCompleted = true;
        }

        // Firestore에 업데이트
        await userService.updateChallengeTaskStatus(
          currentUser!.uid,
          dailyTasks[attendanceTaskIndex].name,
          now,
          isCompleted: dailyTasks[attendanceTaskIndex].isCompleted,
          hasClaimedXP: dailyTasks[attendanceTaskIndex].hasClaimedXP,
          currentAttendance: dailyTasks[attendanceTaskIndex].currentAttendance,
        );

        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
    updateAttendance(); // 앱 실행 시 출석 일수를 업데이트
    _totalEventsCountFuture = _getTotalEventsCount();
    _completedEventsCountFuture = _getCompletedEventsCount();
  }

  @override
  void dispose() {
    super.dispose();
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
      backgroundColor: Colors.white,
      appBar: AppBar(scrolledUnderElevation: 0, title: const Text('도전 과제')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dailyTasks.length,
              itemBuilder: (context, index) {
                double progressValue =
                    dailyTasks[index].isCompleted ? 1.0 : 0.0;

                if (dailyTasks[index].name == '일정 50개 등록하기') {
                  return FutureBuilder<int>(
                    future: _totalEventsCountFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('오류 발생'));
                      } else {
                        int totalEvents = snapshot.data ?? 0;
                        progressValue = totalEvents / 50.0;
                        return _buildTaskItem(dailyTasks[index], progressValue,
                            index, totalEvents);
                      }
                    },
                  );
                }
                if (dailyTasks[index].name == '일정 50개 완료하기') {
                  return FutureBuilder<int>(
                    future: _completedEventsCountFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('오류 발생'));
                      } else {
                        int totalCompletedEvents = snapshot.data ?? 0;
                        progressValue = totalCompletedEvents / 50.0;
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

  Widget _buildTaskItem(DailyTask task, double progressValue, int index,
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
                    if (task.name == '10일 출석하기')
                      Text(
                        '(${task.currentAttendance}/10)',
                        style: TextStyle(
                          color: task.isCompleted ? const Color(0xff4496de) : Colors.amberAccent,
                          fontSize: 10,
                        ),
                      ),
                    if (task.name == '일정 50개 등록하기' && totalEvents != null)
                      Text(
                        '($totalEvents/50)',
                        style: TextStyle(
                          color: task.isCompleted ? const Color(0xff4496de) : Colors.amberAccent,
                          fontSize: 10,
                        ),
                      ),
                    if (task.name == '일정 50개 완료하기' &&
                        totalCompletedEvents != null)
                      Text(
                        '($totalCompletedEvents/50)',
                        style: TextStyle(
                          color: task.isCompleted ? const Color(0xff4496de) : Colors.amberAccent,
                          fontSize: 10,
                        ),
                      ),
                    // 추가: 현재 레벨 표시
                    if (task.name == '10레벨 달성하기')
                      FutureBuilder(
                        future: userService.getUserInfo(currentUser!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('오류 발생',
                                style: TextStyle(color: Colors.red));
                          } else if (snapshot.hasData) {
                            int level =
                                snapshot.data?['level'] ?? 0; // 현재 레벨 가져오기
                            return Text(
                              '($level/10)',
                              style: TextStyle(
                                color: task.isCompleted ? const Color(0xff4496de) : Colors.amberAccent,
                                fontSize: 10,
                              ),
                            );
                          }
                          return Container(); // 데이터가 없을 경우 빈 컨테이너 반환
                        },
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
                        value: task.name == '10일 출석하기'
                            ? task.currentAttendance / 10.0
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
    for (int i = 0; i < dailyTasks.length; i++) {
      var taskStatus = await userService.getChallengeTaskStatus(
          currentUser!.uid, dailyTasks[i].name);
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
    await addDailyTasksToFirestore();
    await Future.wait([
      checkTaskForFiftyEvents(),
      checkTaskForThreeCompletedEvents(),
      checkTaskForLevelTen(),
    ]);
    setState(() {}); // 모든 작업이 완료된 후 UI 업데이트
  }

// "일정 50개 등록하기" 미션 확인 및 업데이트 메소드
  Future<void> checkTaskForFiftyEvents() async {
    final userEventsSnapshot = await firestore
        .collection('events')
        .where('uid', isEqualTo: currentUser!.uid)
        .get();
    int totalEvents = userEventsSnapshot.docs.length;
    totalRegisteredEvents = totalEvents; // 등록된 일정 개수 상태 설정
    // Firebase에 일정 수를 저장하는 메소드 호출

    var taskIndex = dailyTasks.indexWhere((task) => task.name == '일정 50개 등록하기');
    // "일정 15개 등록하기" 미션 확인 및 업데이트
    if (totalEvents >= 50) {
      if (!dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = true; // 미션 완료로 설정
        await userService.updateChallengeTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
          currentAttendance: 0,
        );
      }
    } else {
      if (dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = false; // 미션 미완료로 설정
        await userService.updateChallengeTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
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

    var taskIndex = dailyTasks.indexWhere((task) => task.name == '일정 50개 완료하기');
    // "일정 50개 완료하기" 미션 확인 및 업데이트
    if (completedEvents >= 50) {
      if (!dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = true; // 미션 완료로 설정
        await userService.updateChallengeTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
          currentAttendance: 0,
        );
      }
    } else {
      if (dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = false; // 미션 미완료로 설정
        await userService.updateChallengeTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
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
      dailyTasks[index].isCompleted = true;
    });
    // Firestore에 태스크 완료 상태 저장
    if (currentUser != null) {
      await userService.updateChallengeTaskStatus(
        currentUser!.uid,
        dailyTasks[index].name,
        null,
        isCompleted: true, // isCompleted를 true로 설정
        hasClaimedXP: false, // 획득 여부는 초기화하여 획득 가능 상태로 유지
        currentAttendance: 0,
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
      await userService.updateChallengeTaskStatus(
        currentUser!.uid,
        dailyTasks[index].name,
        currentTime,
        isCompleted: true, // 태스크는 이미 완료된 상태이므로 true로 유지
        hasClaimedXP: true, // 경험치를 청구했으므로 hasClaimedXP를 true로 설정
        currentAttendance: 0,
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
          await userService.getChallengeTaskStatus(currentUser!.uid, task.name);
      if (taskStatus == null) {
        await userService.updateChallengeTaskStatus(
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

  // 레벨 10 달성 여부 확인 및 업데이트 메소드
  Future<void> checkTaskForLevelTen() async {
    if (currentUser == null) return;

    // 사용자 정보를 가져와서 현재 레벨을 확인
    var userInfo = await userService.getUserInfo(currentUser!.uid);
    int level = userInfo?['level'] ?? 0;

    // "레벨 10 달성하기" 태스크 확인 및 업데이트
    var taskIndex = dailyTasks.indexWhere((task) => task.name == '10레벨 달성하기');
    if (level >= 10) {
      if (!dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = true;
        await userService.updateChallengeTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
          null,
          isCompleted: true,
          hasClaimedXP: false,
          currentAttendance: 0,
        );
      }
    } else {
      if (dailyTasks[taskIndex].isCompleted) {
        dailyTasks[taskIndex].isCompleted = false;
        await userService.updateChallengeTaskStatus(
          currentUser!.uid,
          dailyTasks[taskIndex].name,
          null,
          isCompleted: false,
          hasClaimedXP: false,
          currentAttendance: 0,
        );
      }
    }

    setState(() {}); // 레벨 10 달성 상태 변경 시 UI 업데이트
  }
}
