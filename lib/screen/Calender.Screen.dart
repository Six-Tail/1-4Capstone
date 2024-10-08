// Calendar.Screen.dart
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
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

  void _addEvent(String event, String time) {
    setState(() {
      final selectedDay = _selectedDay ?? _focusedDay;
      if (_events[selectedDay] != null) {
        _events[selectedDay]!
            .add(Event(name: event, time: time, isCompleted: false));
      } else {
        _events[selectedDay] = [
          Event(name: event, time: time, isCompleted: false)
        ];
      }
    });
  }

  void _editEvent(int index, String updatedEvent, String updatedTime) {
    if (_selectedDay != null && _events[_selectedDay!] != null) {
      setState(() {
        _events[_selectedDay!]![index].name = updatedEvent;
        _events[_selectedDay!]![index].time = updatedTime; // 수정된 시간 업데이트
      });
    }
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
        _events[_selectedDay!]![index].isCompleted = isCompleted; // 이벤트의 완료 상태 업데이트
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
          title: Center(
            child: Text('$currentYear년 $currentMonth월 통계')
          ),
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
                selectedDay: _selectedDay,
                events: _events,
                onDaySelected: _onDaySelected,
                onPageChanged: _onPageChanged,
              ),
              SizedBox(height: screenHeight * 0.01),
              // EventList 위젯 사용 시
              EventList(
                selectedDay: _selectedDay,
                events: _events[_selectedDay!],
                editEvent: _editEvent,
                deleteEvent: _deleteEvent,
                toggleEventCompletion: _toggleEventCompletion, // 추가된 콜백 전달
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
            onEventAdded: _addEvent,
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
