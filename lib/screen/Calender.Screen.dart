import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todobest_home/Setting.MainPage.dart';
import 'package:todobest_home/community/Community.MainPage.dart';
import 'package:todobest_home/utils/Themes.Colors.dart';
import '../utils/CalenderNavi.dart';
import 'CalenderUtil/EventModal.dart';
import 'Week.Screen.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  _CalenderScreenState createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScrollController _scrollController = ScrollController();

  bool _isExpanded = false;

  // 일정 저장을 위한 맵
  final Map<DateTime, List<String>> _events = {};

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

  void _onPrevMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  // 일정 추가 메서드
  void _addEvent(String event) {
    if (_selectedDay != null) {
      setState(() {
        if (_events[_selectedDay!] != null) {
          _events[_selectedDay!]!.add(event);
        } else {
          _events[_selectedDay!] = [event];
        }
      });
    }
  }

  // 일정 수정 메서드
  void _editEvent(int index, String updatedEvent) {
    if (_selectedDay != null && _events[_selectedDay!] != null) {
      setState(() {
        _events[_selectedDay!]![index] = updatedEvent;
      });
    }
  }

  // 일정 삭제 메서드
  void _deleteEvent(int index) {
    if (_selectedDay != null && _events[_selectedDay!] != null) {
      setState(() {
        _events[_selectedDay!]!.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme1Colors.mainColor,
      appBar: AppBar(
        title: Text(
          'ToDoBest',
          style: TextStyle(
              fontSize: 26,
              color: Theme1Colors.textColor),
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
      body: Column(
        children: [
          CalenderNavi(
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onPrevMonth: _onPrevMonth,
            onNextMonth: _onNextMonth,
            onFormatChanged: _onFormatChanged,
          ),
          if (_calendarFormat == CalendarFormat.week)
            WeekScreen(
              focusedDay: _focusedDay,
              scrollController: _scrollController,
            ),
          if (_calendarFormat != CalendarFormat.week)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      headerVisible: false,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: _onDaySelected,
                      onFormatChanged: _onFormatChanged,
                      onPageChanged: _onPageChanged,
                    ),
                  ],
                ),
              ),
            ),
          if (_selectedDay != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedDay!.toLocal()}의 일정:',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme1Colors.textColor,
                    ),
                  ),
                  ..._events[_selectedDay]?.asMap().entries.map((entry) {
                    int index = entry.key;
                    String event = entry.value;

                    return ListTile(
                      title: Text(event),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => EventModal(
                                  selectedDate: _selectedDay!,
                                  initialValue: event,
                                  editMode: true,
                                  onEventAdded: (updatedEvent) {
                                    _editEvent(index, updatedEvent);
                                  },
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteEvent(index);
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList() ?? [],
                ],
              ),
            ),
        ],
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
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => EventModal(
                            selectedDate: _selectedDay ?? _focusedDay,
                            onEventAdded: _addEvent,
                          ),
                        );
                      },
                      label: const Text('일정 등록'),
                      icon: const Icon(Icons.add_task),
                      backgroundColor: Theme1Colors.textColor,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: AnimatedRotation(
              turns: _isExpanded ? 0.25 : 0,
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
              if (kDebugMode) {
                print('Star clicked');
              }
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
