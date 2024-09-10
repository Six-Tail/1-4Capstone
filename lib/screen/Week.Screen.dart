import 'package:flutter/material.dart';

class WeekScreen extends StatelessWidget {
  final DateTime focusedDay;
  final ScrollController scrollController;

  const WeekScreen({
    required this.focusedDay,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfWeek = focusedDay.subtract(
        Duration(days: focusedDay.weekday - 1));  // 월요일 시작
    final daysOfWeek = List.generate(
        7, (index) => firstDayOfWeek.add(Duration(days: index)));

    return Expanded(
      child: Column(
        children: [
          // 날짜와 요일 표시
          Container(
            color: Colors.black54,
            child: Row(
              children: [
                SizedBox(width: 40),  // 시간 칸과 정렬을 맞추기 위한 여백
                ...daysOfWeek.map((day) {
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          child: Center(
                            child: Text(
                              '${day.month}/${day.day}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                        Container(
                          height: 30,
                          child: Center(
                            child: Text(
                              _dayOfWeek(day.weekday),
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          // 시간과 일정 슬롯 표시
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Row(
                children: [
                  // 시간 표시
                  Column(
                    children: List.generate(24, (index) {
                      return Container(
                        height: 60,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Text(
                            '${index}:00',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }),
                  ),
                  // 일정 슬롯 표시
                  Expanded(
                    child: Column(
                      children: List.generate(24, (hour) {
                        return Row(
                          children: List.generate(7, (dayIndex) {
                            return Expanded(
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
      default:
        return '일';
    }
  }
}
