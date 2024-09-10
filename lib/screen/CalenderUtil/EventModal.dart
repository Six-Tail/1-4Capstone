import 'package:flutter/material.dart';

class EventModal extends StatelessWidget {
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
  Widget build(BuildContext context) {
    TextEditingController eventController = TextEditingController(text: initialValue ?? "");

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 팝업창의 크기를 내용에 맞게 조정
            children: [
              Text(
                editMode ? '일정 수정' : '일정 등록 (${selectedDate.toLocal().toString().split(' ')[0]})',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: eventController,
                decoration: const InputDecoration(hintText: '일정 내용을 입력하세요'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
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
                        onEventAdded(eventController.text);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(editMode ? '수정' : '등록'),
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
