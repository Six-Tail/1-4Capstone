import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Week.Screen.dart';

class CustomCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;

  CustomCalendar({
    required this.selectedDate,
    required this.onDateSelected,
    required this.calendarFormat,
    required this.focusedDay,
  });

  @override
  Widget build(BuildContext context) {
    if (calendarFormat == CalendarFormat.week) {
      return WeekScreen(
        focusedDay: focusedDay,
        scrollController: ScrollController(),
      );
    } else {
      return _buildMonthView(context);
    }
  }

  Widget _buildMonthView(BuildContext context) {
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    final startOfWeek = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday));
    final endOfWeek = lastDayOfMonth.add(Duration(days: DateTime.daysPerWeek - lastDayOfMonth.weekday - 1));

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate the size of each cell
              final cellSize = constraints.maxWidth / 7;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                ),
                itemCount: endOfWeek.difference(startOfWeek).inDays + 1,
                itemBuilder: (context, index) {
                  final date = startOfWeek.add(Duration(days: index));
                  final isSelected = DateUtils.isSameDay(date, selectedDate);

                  return GestureDetector(
                    onTap: () => onDateSelected(date),
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blueAccent : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey[300]!),
                        boxShadow: isSelected
                            ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildDayHeader('일'),
        _buildDayHeader('월'),
        _buildDayHeader('화'),
        _buildDayHeader('수'),
        _buildDayHeader('목'),
        _buildDayHeader('금'),
        _buildDayHeader('토'),
      ],
    );
  }

  Widget _buildDayHeader(String day) {
    return Expanded(
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
