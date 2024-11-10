import 'package:flutter/material.dart';

class CalendarListScreen extends StatefulWidget {
  const CalendarListScreen({super.key});

  @override
  _CalendarListScreenState createState() => _CalendarListScreenState();
}

class _CalendarListScreenState extends State<CalendarListScreen> {
  bool _completedTasksVisible = true;
  bool _completedHabitsVisible = false;
  bool _briefingVisible = true;
  bool _dualViewEnabled = false;
  bool _showImagesInDayView = true;
  bool _showSaturdayInBlue = false;
  double _calendarTextSize = 14.0;
  String _weekStart = '월요일';
  String _timeViewHours = '24시간';
  bool _underlineOnEvents = true; // 일정이 있는 날에 밑줄 표시 여부
  String _highlight = '휴일';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          '캘린더 목록',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xffffffff),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text(
              '완료된 일정, 할 일 보기',
              style: TextStyle(color: Colors.black),
            ),
            value: _completedTasksVisible,
            onChanged: (bool value) {
              setState(() {
                _completedTasksVisible = value;
              });
            },
            activeColor: const Color(0xff73b1e7), // 스위치 색상 설정
          ),
          SwitchListTile(
            title: const Text(
              '완료된 습관 보기',
              style: TextStyle(color: Colors.black),
            ),
            value: _completedHabitsVisible,
            onChanged: (bool value) {
              setState(() {
                _completedHabitsVisible = value;
              });
            },
            activeColor: const Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: const Text(
              '오늘의 브리핑 보기',
              style: TextStyle(color: Colors.black),
            ),
            value: _briefingVisible,
            onChanged: (bool value) {
              setState(() {
                _briefingVisible = value;
              });
            },
            activeColor: const Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: const Text(
              '듀얼뷰 보기',
              style: TextStyle(color: Colors.black),
            ),
            value: _dualViewEnabled,
            onChanged: (bool value) {
              setState(() {
                _dualViewEnabled = value;
              });
            },
            activeColor: const Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: const Text(
              '일 뷰에서 사진 보기',
              style: TextStyle(color: Colors.black),
            ),
            value: _showImagesInDayView,
            onChanged: (bool value) {
              setState(() {
                _showImagesInDayView = value;
              });
            },
            activeColor: const Color(0xff73b1e7),
          ),
          SwitchListTile(
            title: const Text(
              '토요일 파란색으로 보기',
              style: TextStyle(color: Colors.black),
            ),
            value: _showSaturdayInBlue,
            onChanged: (bool value) {
              setState(() {
                _showSaturdayInBlue = value;
              });
            },
            activeColor: const Color(0xff73b1e7),
          ),
          const SizedBox(height: 20),
          const Text(
            '달력 글자 크기',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Slider(
            value: _calendarTextSize,
            min: 10.0,
            max: 24.0,
            divisions: 14,
            label: '${_calendarTextSize.round()}',
            onChanged: (double value) {
              setState(() {
                _calendarTextSize = value;
              });
            },
            activeColor: const Color(0xff73b1e7), // 슬라이더 활성 상태 색상
            inactiveColor: Colors.grey, // 슬라이더 비활성 상태 색상
          ),
          const SizedBox(height: 20),
          const Text(
            '한 주의 시작',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          DropdownButton<String>(
            value: _weekStart,
            onChanged: (String? newValue) {
              setState(() {
                _weekStart = newValue!;
              });
            },
            items: ['월요일', '일요일'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            '타임뷰 표시 시간',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          DropdownButton<String>(
            value: _timeViewHours,
            onChanged: (String? newValue) {
              setState(() {
                _timeViewHours = newValue!;
              });
            },
            items: ['24시간', '12시간'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            '강조 표시',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          DropdownButton<String>(
            value: _highlight,
            items: <String>['휴일', '토', '일'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _highlight = newValue!;
              });
            },
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text(
              '일정이 있는 날에 밑줄 표시',
              style: TextStyle(color: Colors.black),
            ),
            value: _underlineOnEvents,
            onChanged: (bool value) {
              setState(() {
                _underlineOnEvents = value;
              });
            },
            activeColor: const Color(0xff73b1e7),
          ),
        ],
      ),
    );
  }
}
