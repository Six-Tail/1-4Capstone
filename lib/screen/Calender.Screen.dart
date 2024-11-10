// Calendar.Screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'CalenderUtil/custom_calendar.dart';
import 'CalenderUtil/custom_floating_action_button.dart';
import 'CalenderUtil/event.modal.dart';
import 'CalenderUtil/event.model.dart';
import 'CalenderUtil/event_list.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now(); // 현재 날짜로 초기화
  bool _isExpanded = false;
  final Map<DateTime, List<Event>> _events = {};
  final ScrollController _scrollController = ScrollController();
  double _rotationAngle = 0.0; // 버튼의 회전 각도
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // 앱 시작 시 _selectedDay를 오늘 날짜로 설정
    _loadUserEvents(); // 사용자 이벤트 로드
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Firestore에서 사용자 이벤트 로드하는 함수
  void _loadUserEvents() async {
    final eventCollection = FirebaseFirestore.instance.collection('events');
    final userUid = FirebaseAuth.instance.currentUser?.uid; // 현재 사용자 UID 가져오기

    if (userUid != null) {
      try {
        final querySnapshot = await eventCollection
            .where('uid', isEqualTo: userUid) // 현재 사용자 UID에 해당하는 이벤트 조회
            .get();

        // 이벤트를 _events 맵에 추가
        for (var doc in querySnapshot.docs) {
          final eventData = doc.data();
          DateTime startDate = (eventData['startDate'] as Timestamp).toDate(); // Firestore의 Timestamp를 DateTime으로 변환
          String uniqueId = doc.id; // 문서 ID

          // UTC로 변환하여 _events에 추가
          DateTime localDate = DateTime.utc(startDate.year, startDate.month, startDate.day);

          // mounted 속성 체크 후 setState 호출
          if (mounted) {
            setState(() {
              if (_events[localDate] != null) {
                _events[localDate]!.add(Event(
                  id: uniqueId, // Firestore 문서 ID 사용
                  name: eventData['name'],
                  time: eventData['time'],
                  isCompleted: eventData['isCompleted'],
                  startDate: localDate,
                  endDate: localDate,
                  repeat: eventData['repeat'],
                  uid: userUid,
                ));
              } else {
                _events[localDate] = [
                  Event(
                    id: uniqueId, // Firestore 문서 ID 사용
                    name: eventData['name'],
                    time: eventData['time'],
                    isCompleted: eventData['isCompleted'],
                    startDate: localDate,
                    endDate: localDate,
                    repeat: eventData['repeat'],
                    uid: userUid,
                  ),
                ];
              }
            });
          }
        }
        if (kDebugMode) {
          print('사용자 이벤트 로드됨: $_events');
        }
      } catch (e) {
        if (kDebugMode) {
          print('이벤트 로드 실패: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('사용자 UID를 가져올 수 없습니다.');
      }
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    DateTime utcSelectedDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
    if (kDebugMode) {
      print('선택한 UTC 날짜: $utcSelectedDay');
      print('현재 _events 맵: $_events');
    }

    if (_events[utcSelectedDay] != null) {
      if (kDebugMode) {
        print('선택한 날짜에 등록된 이벤트가 있습니다: ${_events[utcSelectedDay]}');
      }
    } else {
      if (kDebugMode) {
        print('선택한 날짜에 등록된 이벤트가 없습니다.');
      }
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      _rotationAngle = _isExpanded ? 0.25 : 0.0; // 90도 회전 (1/4바퀴)
    });
  }

  Future<void> _addEvent(
      String event,
      String time,
      DateTime startDate,
      DateTime? endDate,
      String repeat,
      int repeatCount,
      String userId,
      List<String> selectedDays,
      List<int> selectedDaysInMonth,
      List<int> selectedMonths,
      ) async {
    DateTime currentDate = DateTime.utc(startDate.year, startDate.month, startDate.day);
    DateTime? lastDate = endDate != null ? DateTime.utc(endDate.year, endDate.month, endDate.day) : null;
    String userId = _auth.currentUser?.uid ?? '알 수 없음';

    if (kDebugMode) print("이벤트 추가 시작: $event, 반복: $repeat, 시작일: $startDate");

    await _addEventsBasedOnRepeat(
        event, time, currentDate, lastDate, repeat, repeatCount, userId, selectedDays, selectedDaysInMonth, selectedMonths
    );

    setState(() {
      _selectedDay = startDate;
      _focusedDay = startDate;
    });

    if (kDebugMode) print('이벤트 등록 완료: $event from $startDate to ${endDate ?? '반복 종료 없음'}');
  }

  Future<void> _addEventsBasedOnRepeat(
      String event,
      String time,
      DateTime currentDate,
      DateTime? lastDate,
      String repeat,
      int repeatCount,
      String userId,
      List<String> selectedDays,
      List<int> selectedDaysInMonth,
      List<int> selectedMonths,
      ) async {
    if (repeat == '반복 없음' && lastDate != null) {
      while (!currentDate.isAfter(lastDate)) {
        await _addEventToCalendar(event, time, currentDate, repeat, userId);
        currentDate = currentDate.add(const Duration(days: 1));
      }
    } else {
      for (int count = 0; count < repeatCount; count++) {
        switch (repeat) {
          case '매일':
            await _addEventToCalendar(event, time, currentDate, repeat, userId);
            currentDate = currentDate.add(const Duration(days: 1));
            break;

          case '매주':
            for (String day in selectedDays) {
              DateTime nextOccurrence = currentDate;
              while (true) {
                int targetDay = {
                  '월': 1, '화': 2, '수': 3, '목': 4, '금': 5, '토': 6, '일': 7,
                }[day]!;
                if (nextOccurrence.weekday == targetDay) {
                  await _addEventToCalendar(event, time, nextOccurrence, repeat, userId);
                  break;
                }
                nextOccurrence = nextOccurrence.add(const Duration(days: 1));
              }
            }
            currentDate = currentDate.add(const Duration(days: 7));
            break;

          case '매월':
            for (int day in selectedDaysInMonth) {
              DateTime eventDate = DateTime(currentDate.year, currentDate.month + count, day);
              if (eventDate.day <= DateTime(eventDate.year, eventDate.month + 1, 0).day) {
                await _addEventToCalendar(event, time, eventDate, repeat, userId);
              } else if (kDebugMode) {
                print("매월 이벤트 날짜 오류: $eventDate는 유효하지 않음.");
              }
            }
            break;

          case '매년':
            for (int month in selectedMonths) {
              DateTime eventDate = DateTime(currentDate.year + count, month, currentDate.day);
              if (eventDate.day <= DateTime(eventDate.year, month + 1, 0).day) {
                await _addEventToCalendar(event, time, eventDate, repeat, userId);
              } else if (kDebugMode) {
                print("매년 이벤트 날짜 오류: $eventDate는 유효하지 않음.");
              }
            }
            break;
        }
      }
    }
  }

  Future<void> _addEventToCalendar(
      String event,
      String time,
      DateTime date,
      String repeat,
      String userId,
      ) async {
    if (kDebugMode) print("Firestore에 이벤트 추가 시도: $event, 날짜: $date");

    try {
      DocumentReference value = await FirebaseFirestore.instance.collection('events').add({
        'createdAt': FieldValue.serverTimestamp(), // 서버 시간으로 기록
        'uid': userId,
        'name': event,
        'time': time,
        'startDate': date,
        'endDate': date,
        'repeat': repeat,
        'isCompleted': false,
      });

      String uniqueId = value.id;
      DateTime utcDate = DateTime.utc(date.year, date.month, date.day);

      setState(() {
        if (_events[utcDate] != null) {
          _events[utcDate]!.add(Event(
            id: uniqueId,
            name: event,
            time: time,
            isCompleted: false,
            startDate: utcDate,
            endDate: utcDate,
            repeat: repeat,
            uid: userId,
          ));
        } else {
          _events[utcDate] = [
            Event(
              id: uniqueId,
              name: event,
              time: time,
              isCompleted: false,
              startDate: utcDate,
              endDate: utcDate,
              repeat: repeat,
              uid: userId,
            ),
          ];
        }
      });

      if (kDebugMode) {
        print("Firestore에 이벤트 추가됨: $uniqueId, 날짜: $utcDate");
        print("현재 _events 맵에 저장된 이벤트: $_events");
      }
    } catch (error) {
      if (kDebugMode) print("Firestore에 이벤트 추가 실패: $error");
    }
  }


  void _editEvent(int index, String updatedEvent, String updatedTime,
      DateTime updatedStartDate, DateTime updatedEndDate, String repeat) async {
    if (_selectedDay != null && _events[_selectedDay!] != null) {
      DateTime currentDate = _selectedDay!;

      // 인덱스 유효성 검사
      if (index >= 0 && index < _events[currentDate]!.length) {
        Event currentEvent = _events[currentDate]![index];

        // Firestore에서 문서가 존재하는지 확인
        try {
          final eventDoc = await FirebaseFirestore.instance
              .collection('events')
              .doc(currentEvent.id)
              .get();

          if (eventDoc.exists) {
            // 문서가 존재하면 업데이트합니다.
            await eventDoc.reference.update({
              'name': updatedEvent,
              'time': updatedTime,
              'startDate': updatedStartDate,
              'endDate': updatedEndDate,
              'repeat': repeat,
            });

            // 상태를 업데이트
            setState(() {
              _events[currentDate]![index] = Event(
                id: currentEvent.id, // 기존 이벤트의 ID를 사용
                name: updatedEvent,
                time: updatedTime,
                isCompleted: currentEvent.isCompleted,
                startDate: updatedStartDate,
                endDate: updatedEndDate,
                repeat: repeat,
                uid: currentEvent.uid, // 사용자 ID도 유지
              );
            });

            if (kDebugMode) {
              print('Firebase에서 이벤트가 성공적으로 업데이트되었습니다.');
            }
          } else {
            if (kDebugMode) {
              print('문서가 존재하지 않습니다: ${currentEvent.id}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Firebase 이벤트 업데이트 실패: $e'); // 오류 메시지 출력
          }
        }
      }
    }
  }

  void _deleteEvent(int index) async {
    if (_selectedDay != null && _events[_selectedDay!] != null) {
      final eventToDelete = _events[_selectedDay!]![index];

      setState(() {
        _events[_selectedDay!]!.removeAt(index);
        if (_events[_selectedDay!]!.isEmpty) {
          _events.remove(_selectedDay);
        }
      });

      // Firebase에서 이벤트 문서를 삭제합니다.
      try {
        final eventCollection = FirebaseFirestore.instance.collection('events');
        await eventCollection.doc(eventToDelete.id).delete();
        if (kDebugMode) {
          print('Firebase에서 이벤트가 성공적으로 삭제되었습니다.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Firebase 이벤트 삭제 실패: $e');  // 오류 메시지 출력
        }
      }
    }
  }

  void _toggleEventCompletion(int index, bool isCompleted) async {
    setState(() {
      if (_selectedDay != null && _events[_selectedDay!] != null) {
        // 현재 이벤트 가져오기
        Event currentEvent = _events[_selectedDay!]![index];

        // Firestore에서 문서가 존재하는지 확인
        FirebaseFirestore.instance.collection('events').doc(currentEvent.id).get().then((eventDoc) {
          if (eventDoc.exists) {
            // Firestore에서 isCompleted 값을 업데이트
            eventDoc.reference.update({'isCompleted': isCompleted}).then((_) {
              if (kDebugMode) {
                print('Firebase에서 이벤트 완료 상태가 성공적으로 업데이트되었습니다.');
              }
            }).catchError((error) {
              if (kDebugMode) {
                print('Firebase 이벤트 완료 상태 업데이트 실패: $error');
              }
            });
          }
        });

        // 기존 이벤트 업데이트
        _events[_selectedDay!]![index] = Event(
          id: currentEvent.id, // 기존 ID 유지
          name: currentEvent.name,
          time: currentEvent.time,
          isCompleted: isCompleted, // 새로운 완료 상태로 업데이트
          startDate: currentEvent.startDate,
          endDate: currentEvent.endDate,
          repeat: currentEvent.repeat, // repeat 필드 유지
          uid: currentEvent.uid, // 사용자 ID 유지
        );
      }
    });
  }

  void _showCompletionStats() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('[통계 선택]'),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // 수직 가운데 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 수평 가운데 정렬
            children: [
              ListTile(
                title: const Text('- 이달의 통계'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showMonthlyStats(); // 월 통계 표시
                },
              ),
              ListTile(
                title: const Text('- 전체 통계'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTotalStatsDialog(); // 전체 통계 기간 선택
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMonthlyStats() {
    int completedEvents = 0;
    int totalEvents = 0;

    // 현재 선택된 날짜의 연도와 월을 가져옵니다.
    int currentYear = _selectedDay!.year;
    int currentMonth = _selectedDay!.month;

    // 이벤트를 날짜별로 반복하여 완료된 일정과 총 일정을 세어줍니다.
    _events.forEach((day, events) {
      // 해당 월과 연도에 해당하는 일정만 계산합니다.
      if (day.year == currentYear && day.month == currentMonth) {
        completedEvents += events.where((event) => event.isCompleted).length;
        totalEvents += events.length;
      }
    });

    double completionRate =
        totalEvents > 0 ? (completedEvents / totalEvents) * 100 : 0;

    // 팝업창 띄우기
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
              minHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$currentYear년 $currentMonth월 통계',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 원형 게이지 바 크기 조정
                  SizedBox(
                    width: 100, // 너비
                    height: 100, // 높이
                    child: CircularProgressIndicator(
                      value: completionRate / 100,
                      strokeWidth: 10, // 두께
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('완료한 일정: $completedEvents / $totalEvents'),
                  const SizedBox(height: 20),
                  Text('달성률: ${completionRate.toStringAsFixed(2)}%'),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTotalStatsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('전체 통계 기간 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('3개월'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTotalStats(
                      DateTime.now().subtract(const Duration(days: 90)),
                      DateTime.now(),
                      '최근 3개월 통계'); // 3개월 통계 제목
                },
              ),
              ListTile(
                title: const Text('6개월'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTotalStats(
                      DateTime.now().subtract(const Duration(days: 180)),
                      DateTime.now(),
                      '최근 6개월 통계'); // 6개월 통계 제목
                },
              ),
              ListTile(
                title: const Text('1년'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTotalStats(
                      DateTime.now().subtract(const Duration(days: 365)),
                      DateTime.now(),
                      '최근 1년 통계'); // 1년 통계 제목
                },
              ),
              ListTile(
                title: const Text('전체 기간'),
                onTap: () {
                  Navigator.of(context).pop();

                  int completedEvents = 0;
                  int totalEvents = 0;

                  // 모든 날짜에 있는 이벤트들을 계산
                  _events.forEach((day, events) {
                    completedEvents +=
                        events.where((event) => event.isCompleted).length;
                    totalEvents += events.length;
                  });

                  double completionRate = totalEvents > 0
                      ? (completedEvents / totalEvents) * 100
                      : 0;

                  // 팝업창 띄우기
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Center(child: Text('전체 기간')),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('전체 일정: $totalEvents'),
                            const SizedBox(height: 10),
                            Text('완료한 일정: $completedEvents'),
                            const SizedBox(height: 10),
                            Text('달성률: ${completionRate.toStringAsFixed(2)}%'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: const Text('확인'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('기간 설정'),
                onTap: () async {
                  DateTime today = DateTime.now();
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000), // 과거 선택 가능 시작일을 2000년으로 설정
                    lastDate: DateTime(today.year + 10), // 오늘부터 10년 후까지 선택 가능
                    initialDateRange: DateTimeRange(
                      start: today.subtract(const Duration(days: 30)),
                      // 기본적으로 30일 전부터
                      end: today, // 오늘 날짜
                    ),
                  );

                  if (picked != null) {
                    _showTotalStats(
                        picked.start, picked.end, '${picked.start.year}/${picked.start.month}/${picked.start.day} ~ ${picked.end.year}/${picked.end.month}/${picked.end.day} 통계');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTotalStats(DateTime startDate, DateTime endDate, String title) {
    int completedEvents = 0;
    int totalEvents = 0;

    // 이벤트를 날짜별로 반복하여 완료된 일정과 총 일정을 세어줍니다.
    _events.forEach((day, events) {
      if (day.isAfter(startDate.subtract(const Duration(days: 1))) &&
          day.isBefore(endDate.add(const Duration(days: 1)))) {
        completedEvents += events.where((event) => event.isCompleted).length;
        totalEvents += events.length;
      }
    });

    double completionRate =
    totalEvents > 0 ? (completedEvents / totalEvents) * 100 : 0;

    // 팝업창 띄우기
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(title)), // 동적으로 제목 설정
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('완료한 일정: $completedEvents / $totalEvents'),
              const SizedBox(height: 10),
              Text('달성률: ${completionRate.toStringAsFixed(2)}%'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Image.asset(
          'assets/images/icon.png',
          width: screenWidth * 0.12, // 아이콘 크기
          height: screenHeight * 0.12,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffffffff),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bar_chart,
              color: Color(0xff4496de),
              size: 34,
            ),
            onPressed: _showCompletionStats, // 아이콘 클릭 시 팝업창 띄우는 함수 호출
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: screenHeight * 0.75,
          child: Column(
            children: [
              CustomCalendar(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay!,
                events: _events,
                onDaySelected: _onDaySelected,
                onPageChanged: _onPageChanged,
              ),
              SizedBox(height: screenHeight * 0.01),
              // EventList 위젯 사용 시
              EventList(
                selectedDay: _selectedDay!,
                events: _events,
                editEvent: _editEvent,
                deleteEvent: _deleteEvent,
                toggleEventCompletion: _toggleEventCompletion,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomFloatingActionButton(
        isExpanded: _isExpanded,
        rotationAngle: _rotationAngle,
        toggleMenu: _toggleMenu,
        addEvent: () {
          String userId = "현재 사용자 UID"; // 현재 사용자의 UID를 가져와야 합니다.
          showDialog(
            context: context,
            builder: (context) => EventModal(
              selectedDate: _selectedDay ?? _focusedDay,
              onSave: (event, time, startDate, endDate, repeat, repeatCount, selectedDays, selectedDaysInMonth, selectedMonths) {
                // selectedDaysInMonth 추가
                _addEvent(event, time, startDate, endDate, repeat, repeatCount, userId, selectedDays, selectedDaysInMonth, selectedMonths);
              },
            ),
          );
        },
      ),
    );
  }
}
