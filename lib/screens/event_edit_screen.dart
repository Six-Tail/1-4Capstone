import 'package:flutter/material.dart';

class EventEditScreen extends StatefulWidget {
  @override
  _EventEditScreenState createState() => _EventEditScreenState();
}

class _EventEditScreenState extends State<EventEditScreen> {
  String _selectedCalendar = '기본 캘린더';
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTimeRange? _selectedDateRange;

  // 알림 시간을 선택하는 메소드
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // 이벤트 기간을 선택하는 메소드
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: 7)),
      ),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 이벤트 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('캘린더', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _selectedCalendar,
              items: <String>['기본 캘린더', '회사 캘린더', '개인 캘린더']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCalendar = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            Text('알림 시간', style: TextStyle(fontSize: 18)),
            ListTile(
              title: Text('알림 시간: ${_selectedTime.format(context)}'),
              trailing: Icon(Icons.timer),
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 20),
            Text('이벤트 기간', style: TextStyle(fontSize: 18)),
            ListTile(
              title: Text(_selectedDateRange == null
                  ? '이벤트 기간 선택'
                  : '시작: ${_selectedDateRange!.start}, 종료: ${_selectedDateRange!.end}'),
              trailing: Icon(Icons.date_range),
              onTap: () => _selectDateRange(context),
            ),
          ],
        ),
      ),
    );
  }
}
