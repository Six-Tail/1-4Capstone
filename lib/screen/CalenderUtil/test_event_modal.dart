import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event.model.dart'; // Firestore 추가

class EventModal extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String, String, DateTime, DateTime, String, int) onSave;
  final String? initialValue; // 초기 이벤트 이름
  final String? initialTime; // 초기 시작 시간
  final String? initialEndTime; // 초기 종료 시간
  final bool editMode;
  final String? eventId; // 수정 시 사용되는 이벤트 ID

  const EventModal({
    super.key,
    required this.selectedDate,
    required this.onSave, // onSave를 사용합니다.
    this.initialValue,
    this.initialTime,
    this.initialEndTime,
    this.editMode = false,
    this.eventId, // 이벤트 ID 추가
  });

  @override
  _EventModalState createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  late TextEditingController eventController;
  late TextEditingController repeatCountController; // 반복 횟수 입력 컨트롤러 추가
  DateTime? selectedEndDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool _isAllDay = false;
  DateTime? startDate;
  DateTime? endDate;
  bool _showError = false; // 에러 메시지 표시 여부
  String _errorMessage = ''; // 에러 메시지 내용
  String _selectedRepeat = '반복 없음'; // 기본 반복 주기
  int _repeatCount = 1; // 기본 반복 횟수 1로 설정
  DateTime? repeatEndDate; // 반복 종료 날짜

  final List<String> _repeatOptions = [
    '반복 없음',
    '매일',
    '매주',
    '매월',
    '매년',
  ];

  final List<bool> _selectedWeekdays = List.generate(7, (_) => false); // 요일 선택용
  final List<bool> _selectedDaysOfMonth = List.generate(31, (_) => false); // 날짜 선택용
  final List<bool> _selectedMonths = List.generate(12, (_) => false); // 월 선택용

  @override
  void initState() {
    super.initState();
    eventController = TextEditingController(text: widget.initialValue ?? "");
    repeatCountController = TextEditingController(text: '1'); // 초기 반복 횟수 설정
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
    repeatCountController.dispose(); // 반복 횟수 컨트롤러 해제
    super.dispose();
  }

  // 반복 주기 설정 다이얼로그
  Future<void> _showRepeatDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('반복 설정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 반복 주기 선택 라디오 버튼
                  Column(
                    children: _repeatOptions.map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: _selectedRepeat,
                        onChanged: (value) {
                          setState(() {
                            _selectedRepeat = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (_selectedRepeat == '매주') _buildWeekdaySelection(setState),
                  if (_selectedRepeat == '매월') _buildDayOfMonthSelection(setState),
                  if (_selectedRepeat == '매년') _buildMonthSelection(setState),
                  const SizedBox(height: 10),
                  // 반복 종료 옵션
                  _buildRepeatEndOptions(setState),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 요일 선택 UI (매주 반복용)
  Widget _buildWeekdaySelection(StateSetter setState) {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return Wrap(
      children: List.generate(7, (index) {
        return ChoiceChip(
          label: Text(days[index]),
          selected: _selectedWeekdays[index],
          onSelected: (selected) {
            setState(() {
              _selectedWeekdays[index] = selected;
            });
          },
        );
      }),
    );
  }

  // 날짜 선택 UI (매월 반복용)
  Widget _buildDayOfMonthSelection(StateSetter setState) {
    return Wrap(
      children: List.generate(31, (index) {
        return ChoiceChip(
          label: Text('${index + 1}일'),
          selected: _selectedDaysOfMonth[index],
          onSelected: (selected) {
            setState(() {
              _selectedDaysOfMonth[index] = selected;
            });
          },
        );
      }),
    );
  }

  // 월 선택 UI (매년 반복용)
  Widget _buildMonthSelection(StateSetter setState) {
    return Wrap(
      children: List.generate(12, (index) {
        return ChoiceChip(
          label: Text('${index + 1}월'),
          selected: _selectedMonths[index],
          onSelected: (selected) {
            setState(() {
              _selectedMonths[index] = selected;
            });
          },
        );
      }),
    );
  }

  // 반복 종료 옵션 (기간 설정)
  Widget _buildRepeatEndOptions(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('반복 종료:'),
        ListTile(
          title: const Text('계속 반복'),
          leading: Radio<int>(
            value: 0,
            groupValue: 1,
            onChanged: (value) {},
          ),
        ),
        ListTile(
          title: const Text('반복 횟수 설정'),
          leading: Radio<int>(
            value: 1,
            groupValue: 1,
            onChanged: (value) {},
          ),
          trailing: SizedBox(
            width: 50,
            child: TextField(
              controller: repeatCountController,
              decoration: const InputDecoration(
                hintText: '횟수',
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ),
        ListTile(
          title: const Text('종료 날짜 설정'),
          leading: Radio<int>(
            value: 2,
            groupValue: 1,
            onChanged: (value) {},
          ),
          trailing: TextButton(
            onPressed: () => _selectDate(context),
            child: Text(repeatEndDate != null
                ? DateFormat('yyyy년 MM월 dd일').format(repeatEndDate!)
                : '날짜 선택'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        repeatEndDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            const SizedBox(height: 20),
            TextField(
              controller: eventController,
              decoration: const InputDecoration(labelText: '일정 이름'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _showRepeatDialog, // 반복 설정 다이얼로그 표시
              child: const Text('반복 설정'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (eventController.text.isEmpty) {
                  setState(() {
                    _showError = true;
                    _errorMessage = '일정 이름을 입력해주세요.';
                  });
                  return;
                }

                widget.onSave(
                  eventController.text,
                  _selectedRepeat,
                  startDate!,
                  endDate!,
                  DateFormat('HH:mm').format(startTime!.hour as DateTime),
                  _repeatCount,
                );
              },
              child: Text(widget.editMode ? '수정하기' : '저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
