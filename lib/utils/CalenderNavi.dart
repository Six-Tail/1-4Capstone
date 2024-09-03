import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderNavi extends StatelessWidget {
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<CalendarFormat> onFormatChanged;

  const CalenderNavi({
    required this.focusedDay,
    required this.calendarFormat,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: onPrevMonth, // 이전 달로 이동
          ),
          Row(
            children: [
              Text(
                '${focusedDay.year}년 ${focusedDay.month}월',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8.0),
              ToggleButtons(
                borderColor: Colors.grey,
                selectedBorderColor: Colors.blue,
                selectedColor: Colors.white,
                fillColor: Colors.blue,
                borderRadius: BorderRadius.circular(8),
                constraints: BoxConstraints(minHeight: 30.0, minWidth: 40.0), // 버튼 크기 줄임
                isSelected: [calendarFormat == CalendarFormat.month, calendarFormat == CalendarFormat.week],
                onPressed: (int index) {
                  onFormatChanged(index == 0 ? CalendarFormat.month : CalendarFormat.week);
                },
                children: <Widget>[
                  Text('Month'),
                  Text('Week'),
                ],
              ),
              SizedBox(width: 8.0),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: onNextMonth, // 다음 달로 이동
              ),
            ],
          ),
        ],
      ),
    );
  }
}
