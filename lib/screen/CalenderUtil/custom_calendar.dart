// custom_calendar.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event.model.dart';

class CustomCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Event>> events;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const CustomCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      daysOfWeekHeight: 20,
      locale: 'ko_KR',
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      calendarFormat: CalendarFormat.month,
      onDaySelected: (selectedDay, focusedDay) {
        onDaySelected(selectedDay, focusedDay); // 날짜 선택 시 콜백 호출
      },
      onPageChanged: onPageChanged,
      eventLoader: (day) {
        final eventList = events[day] ?? [];
        return eventList;
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
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Color(0xff4496de),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Color(0xffcae1f6),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        weekendTextStyle: TextStyle(
          color: Colors.black,
        ),
        outsideDaysVisible: false,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isNotEmpty) {
            final totalEvents = events.length;
            final completedEvents =
                events.where((event) => (event as Event).isCompleted).length;

            if (completedEvents == totalEvents) {
              return Positioned(
                bottom: -2,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white, // 배경색 설정
                    shape: BoxShape.circle, // 아이콘 배경을 원형으로 설정
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.black,
                    size: 20, // 아이콘을 살짝 줄여서 배경에 맞춤
                  ),
                ),
              );
            } else {
              final progressWidth = (completedEvents / totalEvents) * 50;

              return Positioned(
                bottom: 4,
                child: Container(
                  width: 50,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: progressWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black,
                        ),
                      ),
                      if (completedEvents < totalEvents)
                        Positioned(
                          right: 0,
                          child: Container(
                            width: 50 - progressWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
          }
          return null; // 이벤트가 없는 경우 마커 표시 안 함
        },
        defaultBuilder: (context, day, focusedDay) {
          TextStyle textStyle;
          if (day.weekday == DateTime.saturday) {
            textStyle = const TextStyle(color: Colors.blue); // 토요일 텍스트 색상
          } else if (day.weekday == DateTime.sunday) {
            textStyle = const TextStyle(color: Colors.red); // 일요일 텍스트 색상
          } else {
            textStyle = const TextStyle(color: Colors.black); // 평일 텍스트 색상
          }
          return Center(
            child: Text(
              '${day.day}',
              style: textStyle,
            ),
          );
        },
      ),
    );
  }
}
