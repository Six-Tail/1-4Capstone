import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EventModal extends StatelessWidget {
  final DateTime selectedDate;
  final Function(String) onEventAdded;
  final String? initialValue;
  final bool editMode;
  final String? eventId;

  const EventModal({
    super.key,
    required this.selectedDate,
    required this.onEventAdded,
    this.initialValue,
    this.editMode = false,
    this.eventId,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                editMode
                    ? '일정 수정'
                    : '일정 등록 (${selectedDate.toLocal().toString().split(' ')[0]})',
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
                  if (editMode)
                    TextButton(
                      onPressed: () async {
                        if (eventId != null) {
                          try {
                            await deleteEventFromDatabase(eventId!);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('삭제 오류: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  TextButton(
                    onPressed: () async {
                      if (eventController.text.isNotEmpty) {
                        try {
                          if (editMode && eventId != null) {
                            await updateEventInDatabase(eventId!, eventController.text);
                          } else {
                            await addEventToDatabase(eventController.text);
                          }
                          onEventAdded(eventController.text);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('오류가 발생했습니다: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('일정 내용을 입력하세요.')),
                        );
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

  Future<void> addEventToDatabase(String eventContent) async {
    final databaseRef = FirebaseDatabase.instance.ref("events");

    await databaseRef.push().set({
      'date': selectedDate.toIso8601String(),
      'event': eventContent,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateEventInDatabase(String eventId, String eventContent) async {
    final databaseRef = FirebaseDatabase.instance.ref("events/$eventId");

    await databaseRef.update({
      'event': eventContent,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteEventFromDatabase(String eventId) async {
    final databaseRef = FirebaseDatabase.instance.ref("events/$eventId");

    await databaseRef.remove();
  }
}
