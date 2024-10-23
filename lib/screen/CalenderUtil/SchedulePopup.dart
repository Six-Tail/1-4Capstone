import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulePopup extends StatefulWidget {
  const SchedulePopup({super.key});

  @override
  _SchedulePopupState createState() => _SchedulePopupState();
}

class _SchedulePopupState extends State<SchedulePopup> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  bool _isAllDay = false;
  String _selectedRepeatOption = '반복 안함';
  int _repeatInterval = 1;

  final List<String> _repeatOptions = [
    '반복 안함',
    '_일마다',
    '_주마다',
    '_개월마다',
    '_년마다',
  ];

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // 시간 선택 함수
  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(_startDate)
          : TimeOfDay.fromDateTime(_endDate),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day,
              picked.hour, picked.minute);
        } else {
          _endDate = DateTime(_endDate.year, _endDate.month, _endDate.day,
              picked.hour, picked.minute);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 등록'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: '제목'),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Text('하루 종일'),
                Switch(
                  value: _isAllDay,
                  onChanged: (value) {
                    setState(() {
                      _isAllDay = value;
                    });
                  },
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('시작:'),
                TextButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(DateFormat('yyyy년 MM월 dd일').format(_startDate)),
                ),
                if (!_isAllDay)
                  TextButton(
                    onPressed: () => _selectTime(context, true),
                    child: Text(DateFormat('HH:mm').format(_startDate)),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('종료:'),
                TextButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text(DateFormat('yyyy년 MM월 dd일').format(_endDate)),
                ),
                if (!_isAllDay)
                  TextButton(
                    onPressed: () => _selectTime(context, false),
                    child: Text(DateFormat('HH:mm').format(_endDate)),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // 반복 옵션
            const Text('반복 설정'),
            Column(
              children: _repeatOptions.map((option) {
                return RadioListTile<String>(
                  title: Row(
                    children: [
                      Text(option),
                      if (option != '반복 안함') // '반복 안함'이 아닌 경우에만 숫자 입력 필드 표시
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '숫자를 입력하세요',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _repeatInterval = int.tryParse(value) ?? 1;
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  value: option,
                  groupValue: _selectedRepeatOption,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedRepeatOption = value!;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 일정 저장 로직
                  if (kDebugMode) {
                    print('일정 저장: $_startDate ~ $_endDate, 반복: $_selectedRepeatOption ($_repeatInterval)');
                  }
                },
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
