// event.modal.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventModal extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String, String, DateTime, DateTime) onEventAdded;
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
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    eventController = TextEditingController(text: widget.initialValue ?? "");
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
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate! : (endDate ?? startDate!),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
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
                widget.editMode ? '일정 수정' : '일정 등록',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    child: Text(DateFormat('yyyy년 MM월 dd일').format(startDate!)),
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
                    child: Text(DateFormat('yyyy년 MM월 dd일').format(endDate!)),
                  ),
                  if (!_isAllDay)
                    TextButton(
                      onPressed: () => _selectTime(context, false),
                      child: Text(endTime != null
                          ? endTime!.format(context)
                          : '종료 시간'),
                    ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (eventController.text.isNotEmpty) {
                        if (startDate == null || endDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('날짜를 선택해야 합니다.')),
                          );
                          return;
                        }

                        if (!_isAllDay && (startTime == null || endTime == null)) {
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

                        widget.onEventAdded(
                          eventController.text,
                          _isAllDay ? '하루 종일' : '$startTimeString - $endTimeString',
                          startDate!,
                          endDate!,
                        );

                        if (kDebugMode) {
                          print('이벤트 등록됨: ${eventController.text}, '
                              '시작 날짜: ${DateFormat('yyyy-MM-dd').format(startDate!)}, '
                              '종료 날짜: ${DateFormat('yyyy-MM-dd').format(endDate!)}, '
                              '시작 시간: $startTimeString, '
                              '종료 시간: $endTimeString, '
                              '하루 종일: ${_isAllDay ? '예' : '아니오'}');
                        }

                        Navigator.of(context).pop();
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
