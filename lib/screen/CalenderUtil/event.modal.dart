import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventModal extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String, String, DateTime, DateTime, String, int, List<String>,
      List<int>, List<int>) onSave;
  final String? initialValue;
  final String? initialTime;
  final String? initialEndTime;
  final bool editMode;
  final String? eventId;

  const EventModal({
    super.key,
    required this.selectedDate,
    required this.onSave,
    this.initialValue,
    this.initialTime,
    this.initialEndTime,
    this.editMode = false,
    this.eventId,
  });

  @override
  _EventModalState createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  late TextEditingController eventController;
  late TextEditingController repeatCountController;
  DateTime? selectedEndDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool _isAllDay = false;
  DateTime? startDate;
  DateTime? endDate;
  bool _showError = false;
  String _errorMessage = '';
  String _selectedRepeat = '반복 없음';
  int _repeatCount = 1;

  final List<String> _repeatOptions = [
    '반복 없음',
    '매일',
    '매주',
    '매월',
    '매년',
  ];

  // 추가된 요일 선택용 상태 변수
  final List<String> _daysOfWeek = ['월', '화', '수', '목', '금', '토', '일'];
  final List<bool> _selectedDays = List.generate(7, (_) => false);

  // 추가된 반복할 일수 선택용 상태 변수
  final List<String> _daysInMonth =
      List.generate(31, (index) => (index + 1).toString());
  final List<bool> _selectedDaysInMonth = List.generate(31, (_) => false);

  // 추가된 연간 반복할 월 선택용 상태 변수
  final List<String> _months = [
    '1월',
    '2월',
    '3월',
    '4월',
    '5월',
    '6월',
    '7월',
    '8월',
    '9월',
    '10월',
    '11월',
    '12월'
  ];
  final List<bool> _selectedMonths = List.generate(12, (_) => false);

  @override
  void initState() {
    super.initState();
    eventController = TextEditingController(text: widget.initialValue ?? "");
    repeatCountController = TextEditingController(text: '1');
    startDate = widget.selectedDate;
    endDate = widget.selectedDate;

    if (widget.initialTime != null && widget.initialTime!.isNotEmpty) {
      final parts = widget.initialTime!.split(':');
      if (parts.length == 2) {
        startTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    if (widget.initialEndTime != null && widget.initialEndTime!.isNotEmpty) {
      final parts = widget.initialEndTime!.split(':');
      if (parts.length == 2) {
        endTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
  }

  @override
  void dispose() {
    eventController.dispose();
    repeatCountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate! : (endDate ?? startDate!),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          if (picked.isAfter(endDate!)) {
            endDate = picked;
          }
          startDate = picked;
        } else {
          if (picked.isBefore(startDate!)) {
            startDate = picked;
          }
          endDate = picked.isBefore(startDate!) ? startDate : picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showCupertinoDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        TimeOfDay selectedTime = isStartTime
            ? (startTime ?? TimeOfDay.now())
            : (endTime ?? TimeOfDay.now());

        return CupertinoAlertDialog(
          title: Text(isStartTime ? '시작 시간 선택' : '종료 시간 선택'),
          content: SizedBox(
            height: 200,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime:
                  DateTime(0, 0, 0, selectedTime.hour, selectedTime.minute),
              onDateTimeChanged: (DateTime newDateTime) {
                selectedTime = TimeOfDay(
                    hour: newDateTime.hour, minute: newDateTime.minute);
              },
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Color(0xff4496de),  // 텍스트 색상 변경
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text(
                '확인',
                style: TextStyle(
                  color: Color(0xff4496de),  // 텍스트 색상 변경
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(selectedTime);
              },
            ),
          ],
        );
      },
    );

    if (pickedTime != null && mounted) {
      setState(() {
        if (isStartTime) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: const Color(0xffffffff),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
          maxWidth: screenWidth * 0.9,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.editMode ? '일정 수정' : '일정 등록',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.01),
                TextField(
                  controller: eventController,
                  decoration: InputDecoration(
                    hintText: '일정 내용을 입력하세요',
                    filled: true,
                    fillColor: Colors.white,
                    // 배경색 설정
                    contentPadding: const EdgeInsets.all(12),
                    // 내부 여백 설정
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), // 둥근 테두리 설정
                      borderSide: const BorderSide(
                        color: Colors.grey, // 테두리 색상 설정
                        width: 1.0, // 테두리 두께 설정
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xff4496de), // 포커스 시 테두리 색상
                        width: 1.5,
                      ),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: screenHeight * 0.01),
                if (_showError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time),
                        SizedBox(width: screenWidth * 0.02),
                        const Text('하루 종일'),
                        Transform.scale(
                          scale: 0.6,
                          child: Switch(
                            value: _isAllDay,
                            onChanged: (value) {
                              setState(() {
                                _isAllDay = value;
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey, // 경계선 색상
                      thickness: 1.0, // 경계선 두께
                      height: 20.0, // 위젯 간 여백
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context, true),
                        child: Text(
                          DateFormat('yy년 MM월 dd일').format(startDate!),
                          style: const TextStyle(
                            color: Color(0xff4496de), // 텍스트 색상 변경
                          ),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context, false),
                        child: Text(
                          DateFormat('yy년 MM월 dd일').format(endDate!),
                          style: const TextStyle(
                            color: Color(0xff4496de), // 텍스트 색상 변경
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_isAllDay) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          TextButton(
                            onPressed: () => _selectTime(context, true),
                            child: Text(
                              startTime != null
                                  ? startTime!.format(context)
                                  : '시작 시간',
                              style: const TextStyle(
                                color: Color(0xff4496de), // 텍스트 색상 변경
                              ),
                            ),
                          )
                        ],
                      ),
                      const Text(
                        ":",
                        style: TextStyle(
                            fontSize: 20, // 글꼴 크기
                            color: Colors.black, // 텍스트 색상
                            fontWeight: FontWeight.bold),
                      ),
                      Column(
                        children: [
                          TextButton(
                            onPressed: () => _selectTime(context, false),
                            child: Text(
                              endTime != null
                                  ? endTime!.format(context)
                                  : '종료 시간',
                              style: const TextStyle(
                                color: Color(0xff4496de), // 텍스트 색상 변경
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                Row(
                  children: [
                    const Icon(Icons.repeat),
                    SizedBox(width: screenWidth * 0.02),
                    const Text('반복'),
                    const Spacer(),
                    DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: _selectedRepeat,
                      items: _repeatOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRepeat = newValue!;
                          _repeatCount =
                              1; // Reset repeat count when repeat option changes
                          _selectedDays.fillRange(
                              0, 7, false); // Reset days of the week
                          _selectedDaysInMonth.fillRange(
                              0, 31, false); // Reset days in month
                          _selectedMonths.fillRange(
                              0, 12, false); // Reset selected months
                        });
                      },
                    ),
                  ],
                ),
                if (_selectedRepeat == '매주') ...[
                  Wrap(
                    spacing: 8.0,
                    children: List.generate(_daysOfWeek.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDays[index] = !_selectedDays[index];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0), // 패딩 조정
                          decoration: BoxDecoration(
                            color: _selectedDays[index]
                                ? Colors.blue
                                : Colors.grey[300], // 선택된 경우 색상 변경
                            shape: BoxShape.circle, // 동그라미 형태
                          ),
                          child: Text(
                            _daysOfWeek[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedDays[index]
                                  ? Colors.white
                                  : Colors.black, // 글자 색상 변경
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
                if (_selectedRepeat == '매월') ...[
                  Wrap(
                    spacing: 8.0, // 동그라미 간의 간격
                    runSpacing: 8.0, // 줄 간격
                    alignment: WrapAlignment.start,
                    // 수정
                    children: List.generate(_daysInMonth.length, (index) {
                      int day = int.parse(_daysInMonth[index]);
                      double circleSize =
                          day < 10 ? 28.0 : 28.0; // 한 자리 숫자와 두 자리 숫자에 따라 크기 조정
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDaysInMonth[index] =
                                !_selectedDaysInMonth[index];
                          });
                        },
                        child: Container(
                          width: circleSize,
                          // 동그라미의 가로 크기
                          height: circleSize,
                          // 동그라미의 세로 크기
                          alignment: Alignment.center,
                          // 텍스트 중앙 정렬
                          decoration: BoxDecoration(
                            color: _selectedDaysInMonth[index]
                                ? Colors.blue
                                : Colors.grey[300], // 선택된 경우 색상 변경
                            shape: BoxShape.circle, // 동그라미 형태
                          ),
                          child: Text(
                            day.toString(), // 1부터 시작하는 숫자
                            style: TextStyle(
                              fontSize: 16, // 텍스트 크기
                              color: _selectedDaysInMonth[index]
                                  ? Colors.white
                                  : Colors.black, // 글자 색상 변경
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
                if (_selectedRepeat == '매년') ...[
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0, // 줄 간격
                    alignment: WrapAlignment.start,
                    children: List.generate(12, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMonths[index] =
                                !_selectedMonths[index]; // 선택된 달 상태 변경
                          });
                        },
                        child: Container(
                          width: 50.0,
                          // 동그라미의 가로 크기
                          height: 50.0,
                          // 동그라미의 세로 크기
                          alignment: Alignment.center,
                          // 텍스트 중앙 정렬
                          decoration: BoxDecoration(
                            color: _selectedMonths[index]
                                ? Colors.blue
                                : Colors.grey[300], // 선택된 경우 색상 변경
                            shape: BoxShape.circle, // 동그라미 형태
                          ),
                          child: Text(
                            _months[index], // 월의 이름을 표시
                            style: TextStyle(
                              fontSize: 16, // 텍스트 크기
                              color: _selectedMonths[index]
                                  ? Colors.white
                                  : Colors.black, // 글자 색상 변경
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
                if (_selectedRepeat != '반복 없음') ...[
                  Row(
                    children: [
                      const Text('반복 횟수: '),
                      SizedBox(
                        width: screenWidth * 0.15,
                        child: TextField(
                          controller: repeatCountController,
                          decoration: const InputDecoration(
                            hintText: '1',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _repeatCount = int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      ),
                      const Text('회'),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: Color(0xff4496de),  // 텍스트 색상 변경
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (eventController.text.isNotEmpty) {
                          if (!_isAllDay &&
                              (startTime == null || endTime == null)) {
                            setState(() {
                              _showError = true;
                              _errorMessage = '시작 시간과 종료 시간을 모두 선택해 주세요.';
                            });
                            return;
                          } else {
                            setState(() {
                              _showError = false;
                            });
                          }

                          if (_selectedRepeat != '반복 없음' && _repeatCount < 1) {
                            setState(() {
                              _showError = true;
                              _errorMessage = '반복 횟수는 1 이상이어야 합니다.';
                            });
                            return;
                          }

                          // Weekly repeat validation: at least one day of the week must be selected
                          if (_selectedRepeat == '매주' &&
                              !_selectedDays.contains(true)) {
                            setState(() {
                              _showError = true;
                              _errorMessage = '반복 하고 싶은 요일을 선택하세요.';
                            });
                            return;
                          }

                          // Monthly repeat validation: at least one day of the month must be selected
                          if (_selectedRepeat == '매월' &&
                              !_selectedDaysInMonth.contains(true)) {
                            setState(() {
                              _showError = true;
                              _errorMessage = '반복 하고 싶은 일수를 선택하세요.';
                            });
                            return;
                          }

                          // Yearly repeat validation: at least one month must be selected
                          if (_selectedRepeat == '매년' &&
                              !_selectedMonths.contains(true)) {
                            setState(() {
                              _showError = true;
                              _errorMessage = '반복 하고 싶은 월을 선택하세요.';
                            });
                            return;
                          }

                          // If all validations pass, continue with event saving
                          String startTimeString = _isAllDay
                              ? '하루 종일'
                              : '${startTime?.hour.toString().padLeft(2, '0')}:${startTime?.minute.toString().padLeft(2, '0')}';
                          String endTimeString = _isAllDay
                              ? '하루 종일'
                              : '${endTime?.hour.toString().padLeft(2, '0')}:${endTime?.minute.toString().padLeft(2, '0')}';

                          List<String> selectedDays = [];
                          for (int i = 0; i < _selectedDays.length; i++) {
                            if (_selectedDays[i]) {
                              selectedDays.add(_daysOfWeek[i]);
                            }
                          }

                          List<int> selectedDaysInMonth = [];
                          for (int i = 0;
                              i < _selectedDaysInMonth.length;
                              i++) {
                            if (_selectedDaysInMonth[i]) {
                              selectedDaysInMonth.add(i + 1);
                            }
                          }

                          List<int> selectedMonths = [];
                          for (int i = 0; i < _months.length; i++) {
                            if (_selectedMonths[i]) {
                              selectedMonths.add(i + 1);
                            }
                          }

                          widget.onSave(
                              eventController.text,
                              _isAllDay
                                  ? '하루 종일'
                                  : '$startTimeString - $endTimeString',
                              startDate!,
                              endDate!,
                              _selectedRepeat,
                              _repeatCount,
                              selectedDays,
                              selectedDaysInMonth,
                              selectedMonths);
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            _showError = true;
                            _errorMessage = '일정 내용을 입력하세요.';
                          });
                        }
                      },
                        child: Text(
                          widget.editMode ? '수정' : '등록',
                          style: const TextStyle(
                            color: Color(0xff4496de),  // 텍스트 색상 변경
                          ),
                        ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
