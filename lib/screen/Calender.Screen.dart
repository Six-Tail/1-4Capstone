import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todobest_home/Setting.MainPage.dart';
import 'package:todobest_home/community/Community.MainPage.dart';
import 'package:todobest_home/utils/Themes.Colors.dart';
import '../rank/RankMore.dart';
import 'CalenderUtil/EventModal.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now(); // 현재 날짜로 초기화
  bool _isExpanded = false;
  final Map<DateTime, List<Event>> _events = {};
  final ScrollController _scrollController = ScrollController();
  double _rotationAngle = 0.0; // 버튼의 회전 각도

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

  void _onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
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

  void _addEvent(String event) {
    setState(() {
      final selectedDay = _selectedDay ?? _focusedDay; // 항상 유효한 날짜를 사용하도록 보장
      if (_events[selectedDay] != null) {
        _events[selectedDay]!.add(Event(name: event, isCompleted: false));
      } else {
        _events[selectedDay] = [Event(name: event, isCompleted: false)];
      }
    });
  }

  void _editEvent(int index, String updatedEvent) {
    if (_selectedDay != null && _events[_selectedDay!] != null) {
      setState(() {
        _events[_selectedDay!]![index].name = updatedEvent;
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

  bool _isAllEventsCompleted(DateTime day) {
    if (_events[day] != null && _events[day]!.isNotEmpty) {
      return _events[day]!.every((event) => event.isCompleted);
    }
    return false;
  }

  // 팝업창 띄우는 함수 추가
  void _showCompletionStats() {
    int completedEvents = 0;
    int totalEvents = 0;

    _events.forEach((day, events) {
      completedEvents += events.where((event) => event.isCompleted).length;
      totalEvents += events.length;
    });

    double completionRate = totalEvents > 0 ? (completedEvents / totalEvents) * 100 : 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('통계'),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        title: Text(
          'ToDoBest',
          style: TextStyle(fontSize: 26, color: Theme1Colors.textColor),
        ),
        centerTitle: true,
        backgroundColor: Theme1Colors.mainColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/icon.png'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: screenHeight * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      onPressed: _showCompletionStats, // 아이콘 클릭 시 팝업창 띄우는 함수 호출
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    // 모든 일정 완료된 날의 개수 표시
                    Text(
                      '${_events.keys.where((day) => _isAllEventsCompleted(day)).length}',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
              ),
              TableCalendar(
                daysOfWeekHeight: 20,
                locale: 'ko_KR',
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                calendarFormat: _calendarFormat,
                onDaySelected: _onDaySelected,
                onFormatChanged: _onFormatChanged,
                onPageChanged: _onPageChanged,
                eventLoader: (day) {
                  return _events[day] ?? [];
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.arrow_back_ios, size: 18),
                  rightChevronIcon: Icon(Icons.arrow_forward_ios, size: 18),
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple.shade200,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  weekendTextStyle: const TextStyle(
                    color: Colors.black, // 기본 주말 텍스트 색상
                  ),
                  outsideDaysVisible: false,
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    // 이벤트가 있는 경우
                    if (events.isNotEmpty) {
                      final totalEvents = events.length;
                      final completedEvents = events
                          .where((event) => (event as Event).isCompleted)
                          .length;

                      // 모든 이벤트가 완료된 경우
                      if (completedEvents == totalEvents) {
                        return const Positioned(
                          bottom: 1,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                        );
                      } else {
                        // 진행바 길이 계산 (총 길이 100으로 가정)
                        final progressWidth =
                            (completedEvents / totalEvents) * 50;

                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 50, // 진행바의 전체 길이
                            height: 6, // 진행바의 높이
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.redAccent, // 기본 배경색 (미완료 일정)
                            ),
                            child: Stack(
                              children: [
                                // 완료된 일정 표시
                                Container(
                                  width: progressWidth, // 완료된 비율만큼의 너비
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.green, // 완료된 일정 색상
                                  ),
                                ),
                                // 미완료 일정 표시
                                if (completedEvents < totalEvents) ...[
                                  Positioned(
                                    right: 0,
                                    child: Container(
                                      width: 50 - progressWidth, // 나머지 비율
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.red, // 미완료 일정 색상
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }
                    }
                    return null; // 이벤트가 없을 경우 마커를 표시하지 않음
                  },
                  // 토요일과 일요일 텍스트 색상 변경
                  defaultBuilder: (context, day, focusedDay) {
                    TextStyle textStyle;
                    if (day.weekday == DateTime.saturday) {
                      textStyle = const TextStyle(
                        color: Colors.blue, // 토요일 텍스트 색상
                      );
                    } else if (day.weekday == DateTime.sunday) {
                      textStyle = const TextStyle(
                        color: Colors.red, // 일요일 텍스트 색상
                      );
                    } else {
                      textStyle = const TextStyle(
                        color: Colors.black, // 평일 텍스트 색상
                      );
                    }

                    return Center(
                      child: Text(
                        '${day.day}',
                        style: textStyle,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Expanded(
                child: _selectedDay != null && _events[_selectedDay!] != null
                    ? ListView.builder(
                        itemCount: _events[_selectedDay!]!.length,
                        itemBuilder: (context, index) {
                          Event event = _events[_selectedDay!]![index];
                          return ListTile(
                            title: Row(
                              children: [
                                Checkbox(
                                  value: event.isCompleted,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      event.isCompleted =
                                          value ?? false; // 이벤트 완료 상태 업데이트
                                    });
                                  },
                                ),
                                Expanded(child: Text(event.name)),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  showDialog(
                                    context: context,
                                    builder: (context) => EventModal(
                                      selectedDate: _selectedDay!,
                                      initialValue: event.name,
                                      editMode: true,
                                      onEventAdded: (updatedEvent) {
                                        _editEvent(index, updatedEvent);
                                      },
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  _deleteEvent(index);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('수정'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('삭제'),
                                  ),
                                ];
                              },
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          '선택된 날짜에 일정이 없습니다.',
                          style: TextStyle(
                            color: Theme1Colors.textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80,
            right: 16,
            child: IgnorePointer(
              ignoring: !_isExpanded,
              child: AnimatedOpacity(
                opacity: _isExpanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'AddTask',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => EventModal(
                            selectedDate: _selectedDay ?? _focusedDay,
                            onEventAdded: _addEvent,
                          ),
                        );
                      },
                      label: const Text('일정 추가'),
                      icon: const Icon(Icons.add),
                      backgroundColor: Theme1Colors.textColor,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: AnimatedRotation(
              turns: _rotationAngle,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                onPressed: _toggleMenu,
                backgroundColor: Theme1Colors.textColor,
                child: Icon(_isExpanded ? Icons.close : Icons.add),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.black),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star, color: Colors.black),
            label: 'Star',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            label: 'More',
          ),
        ],
        selectedItemColor: Theme1Colors.textColor,
        onTap: (int index) {
          switch (index) {
            case 0:
              Get.to(() => const CalenderScreen());
              break;
            case 1:
              Get.to(() => CommunityMainPage());
              break;
            case 2:
              Get.to(() => const RankMore());
              break;
            case 3:
              Get.to(() => SettingMainPage());
              break;
          }
        },
      ),
    );
  }
}

class Event {
  String name;
  bool isCompleted;

  Event({required this.name, this.isCompleted = false});
}
