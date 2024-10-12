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

class _CalenderScreenState extends State<CalenderScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now(); // 현재 날짜로 초기화
  bool _isExpanded = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final Map<DateTime, List<Event>> _events = {};
  final ScrollController _scrollController = ScrollController();
  double _rotationAngle = 0.0; // 버튼의 회전 각도
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // 앱 시작 시 _selectedDay를 오늘 날짜로 설정
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay; // 선택된 날짜 업데이트
      _focusedDay = focusedDay; // 포커스된 날짜 업데이트

      // 선택한 날짜 로그 출력
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
      DateTime endDate, String repeat, int repeatCount) {
    setState(() {
      DateTime currentDate = startDate.toUtc(); // UTC로 변환

      // 반복 로직
      for (int count = 0; count < repeatCount; count++) {
        // 선택한 날짜에 이벤트 추가
        if (_events[currentDate] != null) {
          _events[currentDate]!.add(Event(
            name: event,
            time: time,
            isCompleted: false,
            startDate: startDate.toUtc(),
            endDate: endDate.toUtc(),
            repeat: repeat,
          ));
        } else {
          _events[currentDate] = [
            Event(
              name: event,
              time: time,
              isCompleted: false,
              startDate: startDate.toUtc(),
              endDate: endDate.toUtc(),
              repeat: repeat,
            ),
          ];
        }

        // 반복에 따른 날짜 변경
        switch (repeat) {
          case '매일':
            currentDate = currentDate.add(const Duration(days: 1));
            break;
          case '매주':
            currentDate = currentDate.add(const Duration(days: 7));
            break;
          case '매월':
          // 현재 월의 마지막 날을 확인
            int nextMonth = currentDate.month == 12 ? 1 : currentDate.month + 1;
            int year = currentDate.month == 12 ? currentDate.year + 1 : currentDate.year;

            // 새로운 날짜를 설정
            DateTime newDate = DateTime(year, nextMonth, currentDate.day);
            // 새로운 날짜가 다음 달의 마지막 날 이후인지 확인
            if (newDate.month != nextMonth) {
              newDate = DateTime(year, nextMonth + 1, 0); // 다음 달의 마지막 날
            }
            currentDate = newDate;
            break;
          case '매년':
            currentDate = DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
            break;
          default:
            break; // 더 이상의 반복 없음
        }
      }

      // 선택된 날짜를 이벤트의 시작 날짜로 변경
      _selectedDay = startDate; // 선택된 날짜 업데이트
      _focusedDay = startDate; // 포커스된 날짜 업데이트

      // 디버그 메시지
      if (kDebugMode) {
        print('일정 등록됨: $event from $startDate to $endDate (반복: $repeat, 횟수: $repeatCount)');
        print('현재 이벤트: $_events');
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xffc6dff5),
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
        backgroundColor: const Color(0xffc6dff5), // 네이게이션 바 배경색
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
