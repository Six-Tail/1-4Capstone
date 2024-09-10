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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: theme.primaryColor),
            onPressed: onPrevMonth,
          ),
          Row(
            children: [
              Text(
                '${focusedDay.year}년 ${focusedDay.month}월',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 8.0),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ToggleButtons(
                  borderColor: theme.primaryColor,
                  selectedBorderColor: theme.primaryColor,
                  selectedColor: Colors.white,
                  fillColor: theme.primaryColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  constraints: const BoxConstraints(
                    minHeight: 24.0,
                    minWidth: 36.0,
                  ),
                  isSelected: [
                    calendarFormat == CalendarFormat.month,
                    calendarFormat == CalendarFormat.week,
                  ],
                  onPressed: (int index) {
                    onFormatChanged(
                      index == 0 ? CalendarFormat.month : CalendarFormat.week,
                    );
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('월', style: TextStyle(fontSize: 14)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('주', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: Icon(Icons.chevron_right, color: theme.primaryColor),
                onPressed: onNextMonth,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
