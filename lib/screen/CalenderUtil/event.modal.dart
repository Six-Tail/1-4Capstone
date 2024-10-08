import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventModal extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String, String) onEventAdded;
  final String? initialValue;
  final String? initialTime;
  final String? initialEndTime;
  final bool editMode;

  const EventModal({
    super.key,
    required this.selectedDate,
    required this.onEventAdded,
    this.initialValue,
    this.initialTime,
    this.initialEndTime,
    this.editMode = false,
  });

  @override
  _EventModalState createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  late TextEditingController eventController;
  DateTime? selectedEndDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool _isAllDay = false;
  DateTime? adjustedStartDate; // 시작 날짜 조정 변수 추가

  @override
  void initState() {
    super.initState();
    eventController = TextEditingController(text: widget.initialValue ?? "");
    adjustedStartDate = widget.selectedDate; // 초기 시작 날짜 설정

    // 초기 시간 설정
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
    selectedEndDate = widget.selectedDate; // 초기 종료 날짜 설정
  }

  @override
  void dispose() {
    eventController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? adjustedStartDate!
          : (selectedEndDate ?? adjustedStartDate!),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          // 종료 날짜가 시작 날짜보다 이전인 경우 종료 날짜를 시작 날짜로 설정
          if (picked.isAfter(selectedEndDate!)) {
            selectedEndDate = picked;
          }
          adjustedStartDate = picked; // 시작 날짜 조정
        } else {
          // 시작 날짜가 종료 날짜보다 이후인 경우 시작 날짜를 종료 날짜로 설정
          if (picked.isBefore(adjustedStartDate!)) {
            adjustedStartDate = picked; // 시작 날짜를 종료 날짜로 설정
          }
          selectedEndDate =
              picked.isBefore(adjustedStartDate!) ? adjustedStartDate : picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.6,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.editMode
                    ? '일정 수정'
                    : '일정 등록',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextField(
                controller: eventController,
                decoration: const InputDecoration(hintText: '일정 내용을 입력하세요'),
                maxLines: 3,
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  const Icon(Icons.access_time), // 시계 아이콘 추가
                  SizedBox(width: screenWidth * 0.02),
                  const Text('하루 종일'),
                  Transform.scale(
                    scale: 0.6, // 스위치 크기 줄이기
                    child: Switch(
                      value: _isAllDay,
                      onChanged: (value) {
                        setState(() {
                          _isAllDay = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('시작 날짜:'),
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text(
                        DateFormat('yyyy년 MM월 dd일').format(adjustedStartDate!)),
                  ),
                  if (!_isAllDay)
                    TextButton(
                      onPressed: () => _selectTime(context, true),
                      child: Text(startTime != null
                          ? startTime!.format(context)
                          : '시작 시간'),
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('종료 날짜:'),
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text(
                        DateFormat('yyyy년 MM월 dd일').format(selectedEndDate!)),
                  ),
                  if (!_isAllDay)
                    TextButton(
                      onPressed: () => _selectTime(context, false),
                      child: Text(
                          endTime != null ? endTime!.format(context) : '종료 시간'),
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 팝업 닫기
                    },
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (eventController.text.isNotEmpty) {
                        // 날짜가 선택되었는지 확인
                        if (adjustedStartDate == null ||
                            selectedEndDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('날짜를 선택해야 합니다.')),
                          );
                          return;
                        }

                        if (!_isAllDay &&
                            (startTime == null || endTime == null)) {
                          // 시간이 선택되지 않았을 때 경고 메시지
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('시작 및 종료 시간을 선택하세요')),
                          );
                          return;
                        }

                        String startTimeString = _isAllDay
                            ? '하루 종일'
                            : '${startTime?.hour.toString().padLeft(2, '0')}:${startTime?.minute.toString().padLeft(2, '0')}';
                        String endTimeString = _isAllDay
                            ? '하루 종일'
                            : '${endTime?.hour.toString().padLeft(2, '0')}:${endTime?.minute.toString().padLeft(2, '0')}';

                        // 이벤트를 등록하는 로직 (시작 및 종료 날짜를 기반으로 여러 날짜에 등록)
                        for (DateTime date = adjustedStartDate!;
                            date.isBefore(
                                selectedEndDate!.add(const Duration(days: 1)));
                            date = date.add(const Duration(days: 1))) {
                          widget.onEventAdded(
                              eventController.text,
                              _isAllDay
                                  ? '하루 종일'
                                  : '$startTimeString - $endTimeString');
                        }

                        Navigator.of(context).pop(); // 팝업 닫기
                      }
                    },
                    child: Text(widget.editMode ? '수정' : '등록'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
