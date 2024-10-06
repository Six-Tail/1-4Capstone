import 'package:flutter/material.dart';

class EventModal extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String, String) onEventAdded; // 시간 정보도 함께 받도록 수정
  final String? initialValue; // 수정 모드에서 사용
  final String? initialTime; // 수정 모드에서 사용할 시간 정보
  final bool editMode; // 수정 모드 여부

  const EventModal({
    super.key,
    required this.selectedDate,
    required this.onEventAdded,
    this.initialValue,
    this.initialTime,
    this.editMode = false,
  });

  @override
  _EventModalState createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  late TextEditingController eventController;
  late TextEditingController timeController; // 시간 입력 필드 추가

  @override
  void initState() {
    super.initState();
    // 초기 값 설정
    eventController = TextEditingController(text: widget.initialValue ?? "");
    timeController = TextEditingController(text: widget.initialTime ?? ""); // 초기 시간 값 설정
  }

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 dispose 호출
    eventController.dispose();
    timeController.dispose(); // 시간 컨트롤러도 dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        // 화면 크기를 제한하는 ConstrainedBox 추가
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.6, // 팝업 창의 최대 높이를 화면의 60%로 제한
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 팝업창의 크기를 내용에 맞게 조정
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
              TextField(
                controller: timeController, // 시간 입력 필드
                decoration: const InputDecoration(hintText: '시간을 입력하세요 (예: 14:30)'),
                keyboardType: TextInputType.datetime, // 시간 입력 전용 키보드
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
                      if (eventController.text.isNotEmpty && timeController.text.isNotEmpty) {
                        widget.onEventAdded(eventController.text, timeController.text); // 일정 내용과 시간 정보를 함께 전달
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
