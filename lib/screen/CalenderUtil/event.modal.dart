// event.modal.dart
import 'package:flutter/material.dart';

class EventModal extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String, String) onEventAdded; // 시간 정보도 함께 받도록 수정
  final String? initialValue; // 수정 모드에서 사용
  final String? initialTime; // 수정 모드에서 사용할 시간 정보
  final String? initialEndTime; // 수정 모드에서 사용할 종료 시간 정보
  final bool editMode; // 수정 모드 여부

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
  TimeOfDay? startTime; // 시작 시간
  TimeOfDay? endTime; // 종료 시간
  DateTime? selectedEndDate; // 선택한 종료 날짜

  @override
  void initState() {
    super.initState();
    eventController = TextEditingController(text: widget.initialValue ?? "");

    // TimeOfDay 초기화
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

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (startTime ?? TimeOfDay.now()) : (endTime ?? TimeOfDay.now()),
    );

    // Check if the widget is still mounted before calling setState
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
                    : '일정 등록 (${widget.selectedDate.toLocal().toString().split(' ')[0]})',
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      onTap: () => _selectTime(context, true),
                      decoration: InputDecoration(
                        hintText: startTime != null ? startTime!.format(context) : '시작 시간',
                        suffixIcon: const Icon(Icons.access_time),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // 간격 추가
                  const Icon(Icons.arrow_forward), // 오른쪽 화살표 아이콘
                  const SizedBox(width: 10), // 간격 추가
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      onTap: () => _selectTime(context, false),
                      decoration: InputDecoration(
                        hintText: endTime != null ? endTime!.format(context) : '종료 시간',
                        suffixIcon: const Icon(Icons.access_time),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
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
                      if (eventController.text.isNotEmpty && startTime != null && endTime != null) {
                        String startTimeString = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
                        String endTimeString = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
                        widget.onEventAdded(eventController.text, '$startTimeString - $endTimeString'); // 일정 내용과 시간 정보를 함께 전달
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
