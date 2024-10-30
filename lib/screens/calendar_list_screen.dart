import 'package:flutter/material.dart';

class CalendarListScreen extends StatefulWidget {
  final bool isDarkMode;

  CalendarListScreen({required this.isDarkMode});

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
  String _theme = '라이트';
  bool _underlineOnEvents = true; // 일정이 있는 날에 밑줄 표시 여부
  String _highlight = '휴일';

  ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
    ),
  );

  ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
    ),
  );

  late ThemeData _currentTheme;

  @override
  void initState() {
    super.initState();
    // 초기 테마 설정: isDarkMode 값에 따라 라이트 또는 다크 테마 적용
    _currentTheme = widget.isDarkMode ? _darkTheme : _lightTheme;
    _theme = widget.isDarkMode ? '다크' : '라이트';
  }

  void _changeTheme(String theme) {
    setState(() {
      if (theme == '라이트') {
        _currentTheme = _lightTheme;
      } else {
        _currentTheme = _darkTheme;
      }
      _theme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text('캘린더 목록'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 완료된 일정, 할 일 보기
            SwitchListTile(
              title: Text('완료된 일정, 할 일 보기'),
              value: _completedTasksVisible,
              onChanged: (bool value) {
                setState(() {
                  _completedTasksVisible = value;
                });
              },
            ),
            // 완료된 습관 보기
            SwitchListTile(
              title: Text('완료된 습관 보기'),
              value: _completedHabitsVisible,
              onChanged: (bool value) {
                setState(() {
                  _completedHabitsVisible = value;
                });
              },
            ),
            // 오늘의 브리핑 보기
            SwitchListTile(
              title: Text('오늘의 브리핑 보기'),
              value: _briefingVisible,
              onChanged: (bool value) {
                setState(() {
                  _briefingVisible = value;
                });
              },
            ),
            // 듀얼뷰 보기
            SwitchListTile(
              title: Text('듀얼뷰 보기'),
              value: _dualViewEnabled,
              onChanged: (bool value) {
                setState(() {
                  _dualViewEnabled = value;
                });
              },
            ),
            // 일 뷰에서 사진 보기
            SwitchListTile(
              title: Text('일 뷰에서 사진 보기'),
              value: _showImagesInDayView,
              onChanged: (bool value) {
                setState(() {
                  _showImagesInDayView = value;
                });
              },
            ),
            // 토요일 파란색으로 보기
            SwitchListTile(
              title: Text('토요일 파란색으로 보기'),
              value: _showSaturdayInBlue,
              onChanged: (bool value) {
                setState(() {
                  _showSaturdayInBlue = value;
                });
              },
            ),
            SizedBox(height: 20),
            // 달력 글자 크기
            Text('달력 글자 크기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            ),
            SizedBox(height: 20),
            // 한 주의 시작
            Text('한 주의 시작', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            // 타임뷰 표시 시간
            Text('타임뷰 표시 시간', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('강조 표시', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _highlight,
              items: <String>['휴일', '토', '일'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _highlight = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('일정이 있는 날에 밑줄 표시'),
              value: _underlineOnEvents,
              onChanged: (bool value) {
                setState(() {
                  _underlineOnEvents = value;
                });
              },
            ),
           ],
        ),
      ),
    );
  }
}
