// Calendar.Screen.dart

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todobest_home/utils/Themes.Colors.dart';

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

class _CalenderScreenState extends State<CalenderScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now(); // 현재 날짜로 초기화
  bool _isExpanded = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  double _rotationAngle = 0.0; // 버튼의 회전 각도
  final Map<DateTime, List<Event>> _events = {};
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // 앱 시작 시 _selectedDay 오늘 날짜로 설정
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay.toUtc(); // 선택된 날짜를 UTC로 변환
      _focusedDay = focusedDay.toUtc(); // 포커스된 날짜를 UTC로 변환

      if (kDebugMode) {
        print('선택한 날짜: ${_selectedDay!}');
      }
    });
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

  // 이벤트 추가 시 팝업에서 선택한 날짜 기반으로 이벤트를 추가하는 함수
  // 팝업에서 이벤트를 추가할 때 사용되는 함수
  void _addEvent(String event, String time, DateTime startDate,
      DateTime? endDate, String repeat, int repeatCount) {
    setState(() {
      DateTime currentDate = DateTime.utc(
          startDate.year, startDate.month, startDate.day); // UTC로 변환하여 시간 고정
      DateTime? lastDate = endDate != null
          ? DateTime.utc(endDate.year, endDate.month, endDate.day)
          : null; // endDate가 있을 때만 사용

      // 반복이 "반복 없음"일 때 시작일과 종료일까지 이벤트 등록
      if (repeat == '반복 없음' && lastDate != null) {
        while (!currentDate.isAfter(lastDate)) {
          _addEventToCalendar(event, time, currentDate, repeat);
          // 다음 날로 이동
          currentDate = currentDate.add(const Duration(days: 1));
        }
      }
      // 반복이 활성화된 경우
      else {
        // 반복 횟수에 따른 이벤트 등록 로직
        for (int count = 0; count < repeatCount; count++) {
          // 반복에 따른 날짜 변경
          switch (repeat) {
            case '매일':
              _addEventToCalendar(event, time, currentDate, repeat);
              currentDate = currentDate.add(const Duration(days: 1));
              break;
            case '매주':
              _addEventToCalendar(event, time, currentDate, repeat);
              currentDate = currentDate.add(const Duration(days: 7));
              break;
            case '매월':
              // 현재 월의 마지막 날 계산
              int lastDayOfCurrentMonth =
                  DateTime(currentDate.year, currentDate.month + 1, 0).day;
              // 현재 날짜가 마지막 날일 경우
              if (currentDate.day == lastDayOfCurrentMonth) {
                _addEventToCalendar(
                    event,
                    time,
                    DateTime.utc(currentDate.year, currentDate.month,
                        lastDayOfCurrentMonth),
                    repeat);
                // 다음 달의 마지막 날로 이동
                currentDate = DateTime.utc(currentDate.year,
                    currentDate.month + 1, lastDayOfCurrentMonth);
              } else {
                // 마지막 날이 아닐 경우에는 해당 날짜에 등록
                _addEventToCalendar(event, time, currentDate, repeat);
                // 다음 달로 이동
                currentDate = DateTime.utc(
                    currentDate.year, currentDate.month + 1, currentDate.day);
              }
              break;
            case '매년':
              _addEventToCalendar(event, time, currentDate, repeat);
              currentDate = DateTime.utc(
                  currentDate.year + 1, currentDate.month, currentDate.day);
              break;
            default:
              break;
          }

          // currentDate.day 값을 출력
          if (kDebugMode) {
            print('현재 currentDate.day: ${currentDate.day}');
          }
        }
      }

      _selectedDay = startDate.toUtc(); // 선택된 날짜를 UTC로 변환
      _focusedDay = startDate.toUtc(); // 포커스된 날짜를 UTC로 변환

      if (kDebugMode) {
        print(
            '일정 등록됨: $event from $startDate to ${endDate ?? '반복 종료 없음'} (반복: $repeat, 횟수: $repeatCount)');
        print('현재 이벤트: $_events');
      }
    });
  }

// 이벤트를 캘린더에 추가하는 헬퍼 함수
  void _addEventToCalendar(
      String event, String time, DateTime date, String repeat) {
    if (_events[date] != null) {
      _events[date]!.add(Event(
        name: event,
        time: time,
        isCompleted: false,
        startDate: date,
        endDate: date,
        repeat: repeat,
      ));
    } else {
      _events[date] = [
        Event(
          name: event,
          time: time,
          isCompleted: false,
          startDate: date,
          endDate: date,
          repeat: repeat,
        ),
      ];
    }
  }

  void _editEvent(int index, String updatedEvent, String updatedTime,
      DateTime updatedStartDate, DateTime updatedEndDate, String repeat) {
    setState(() {
      // 선택된 날짜 범위에 해당하는 이벤트를 업데이트
      DateTime currentDate = updatedStartDate;
      while (currentDate.isBefore(updatedEndDate) ||
          currentDate.isAtSameMomentAs(updatedEndDate)) {
        if (_events[currentDate] != null &&
            _events[currentDate]!.length > index) {
          // Event 객체를 새로 생성하여 업데이트
          _events[currentDate]![index] = Event(
            name: updatedEvent,
            time: updatedTime,
            isCompleted: _events[currentDate]![index].isCompleted,
            // 기존 완료 상태 유지
            startDate: updatedStartDate,
            // 새 시작 날짜
            endDate: updatedEndDate,
            // 새 종료 날짜
            repeat: repeat, // repeat 필드를 추가
          );
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    });
  }

  void _deleteEvent(int index) {
    if (_selectedDay != null && _events[_selectedDay!] != null) {
      setState(() {
        _events[_selectedDay!]!.removeAt(index);
        // 삭제 후, 이벤트가 없을 경우 해당 날짜에 대한 항목 삭제
        if (_events[_selectedDay!]!.isEmpty) {
          _events.remove(_selectedDay); // 비어있으면 해당 날짜의 이벤트를 맵에서 삭제
        }
      });
    }
  }

  void _toggleEventCompletion(int index, bool isCompleted) {
    setState(() {
      if (_selectedDay != null && _events[_selectedDay!] != null) {
        // 기존 완료 상태를 토글
        Event currentEvent = _events[_selectedDay!]![index];

        _events[_selectedDay!]![index] = Event(
          name: currentEvent.name,
          time: currentEvent.time,
          isCompleted: isCompleted,
          // 새로운 완료 상태로 업데이트
          startDate: currentEvent.startDate,
          endDate: currentEvent.endDate,
          repeat: currentEvent.repeat, // repeat 필드 추가
        );
      }
    });
  }

  void _showCompletionStats() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('통계 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('월 통계'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showMonthlyStats(); // 월 통계 표시
                },
              ),
              ListTile(
                title: const Text('전체 통계'),
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
          title: Center(child: Text('$currentYear년 $currentMonth월 통계')),
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
                      DateTime.now());
                },
              ),
              ListTile(
                title: const Text('6개월'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTotalStats(
                      DateTime.now().subtract(const Duration(days: 180)),
                      DateTime.now());
                },
              ),
              ListTile(
                title: const Text('1년'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTotalStats(
                      DateTime.now().subtract(const Duration(days: 365)),
                      DateTime.now());
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
                        picked.start, picked.end); // 선택된 날짜 범위로 통계 표시
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTotalStats(DateTime startDate, DateTime endDate) {
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
              child: Text(
                  '${startDate.year}년 ${startDate.month}월 ${startDate.day}일 ~ ${endDate.year}년 ${endDate.month}월 ${endDate.day}일 통계')),
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
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check_circle,
              color: Colors.greenAccent,
              size: 20,
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
              // 달력 형식 선택 버튼 추가
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _calendarFormat = CalendarFormat.month;
                        });
                      },
                      child: Text(
                        '월간',
                        style: TextStyle(
                            color: _calendarFormat == CalendarFormat.month
                                ? Colors.blueGrey
                                : Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _calendarFormat = CalendarFormat.week;
                        });
                      },
                      child: Text(
                        '주간',
                        style: TextStyle(
                          color: _calendarFormat == CalendarFormat.week
                              ? Colors.blueGrey
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
          showDialog(
            context: context,
            builder: (context) => EventModal(
              selectedDate: _selectedDay ?? _focusedDay,
              onSave: (event, time, startDate, endDate, repeat, repeatCount) {
                _addEvent(event, time, startDate, endDate, repeat, repeatCount);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: const Color(0xffb7d3e8),
        backgroundColor: const Color(0xffffffff), // 네이게이션 바 배경색
        key: _bottomNavigationKey,
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.chat, size: 30),
          Icon(Icons.star_border, size: 30),
          Icon(Icons.more_horiz, size: 30),
        ],
      ),
    );
  }
}
