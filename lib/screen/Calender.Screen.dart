import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todobest_home/Setting.MainPage.dart';
import 'package:todobest_home/community/Community.MainPage.dart';
import 'package:todobest_home/utils/Themes.Colors.dart';
import 'package:todobest_home/rank/Rank.MainPage.dart';
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
  DateTime? _selectedDay;
  bool _isExpanded = false;
  final Map<DateTime, List<String>> _events = {};

  final ScrollController _scrollController = ScrollController();

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

  void _editEvent(int index, String updatedEvent) {
    if (_selectedDay != null && _events[_selectedDay!] != null) {
      setState(() {
        _events[_selectedDay!]![index] = updatedEvent;
      });
    }
  }

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
              fontSize: 26, color: Theme1Colors.textColor),
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
          TableCalendar(
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
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _selectedDay != null && _events[_selectedDay!] != null
                ? ListView.builder(
              itemCount: _events[_selectedDay!]!.length,
              itemBuilder: (context, index) {
                String event = _events[_selectedDay!]![index];
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
              Get.to(() => RankingPage());
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
