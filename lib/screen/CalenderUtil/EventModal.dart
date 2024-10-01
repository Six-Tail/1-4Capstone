import 'package:flutter/material.dart';

class EventModal extends StatefulWidget {
  final DateTime selectedDate;
  final Function(String) onEventAdded;
  final String? initialValue; // 수정 모드에서 사용
  final bool editMode; // 수정 모드 여부

  const EventModal({
    super.key,
    required this.selectedDate,
    required this.onEventAdded,
    this.initialValue,
    this.editMode = false,
  });

  @override
  _EventModalState createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  late TextEditingController eventController;

  @override
  void initState() {
    super.initState();
    // 초기 값 설정
    eventController = TextEditingController(text: widget.initialValue ?? "");
  }

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 dispose 호출
    eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox( // 화면 크기를 제한하는 ConstrainedBox 추가
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
                    : '일정 등록 (${widget.selectedDate.toLocal().toString().split(
                    ' ')[0]})',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextField(
                controller: eventController,
                decoration: const InputDecoration(hintText: '일정 내용을 입력하세요'),
                maxLines: 3,
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
                      if (eventController.text.isNotEmpty) {
                        widget.onEventAdded(
                            eventController.text); // 이벤트 추가 또는 수정
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
