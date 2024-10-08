// event_list.dart
import 'package:flutter/material.dart';

import 'event.modal.dart';
import 'event.model.dart';

class EventList extends StatelessWidget {
  final DateTime? selectedDay;
  final List<Event>? events;
  final Function(int index, String updatedEvent, String updatedTime) editEvent;
  final Function(int index) deleteEvent;
  final Function(int index, bool isCompleted) toggleEventCompletion; // 체크박스 상태를 업데이트할 콜백 추가


  const EventList({
    super.key,
    required this.selectedDay,
    required this.events,
    required this.editEvent,
    required this.deleteEvent,
    required this.toggleEventCompletion, // 추가된 인자
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: selectedDay != null && events != null
          ? ListView.builder(
        itemCount: events!.length,
        itemBuilder: (context, index) {
          Event event = events![index];
          return Container(
            margin: const EdgeInsets.symmetric(
                vertical: 4.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white, // 일정 카드 배경색
              borderRadius: BorderRadius.circular(12.0), // 모서리 둥글게
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26, // 그림자 색상
                  blurRadius: 4.0, // 흐림 정도
                  offset: Offset(0, 2), // 그림자 위치
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12.0), // 패딩 추가
              title: Row(
                children: [
                  Checkbox(
                    value: event.isCompleted,
                    onChanged: (bool? value) {
                      toggleEventCompletion(index, value ?? false); // 체크박스 상태 업데이트
                    },
                  ),
                  Expanded(
                    child: Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 16.0, // 글자 크기
                        fontWeight: FontWeight.bold, // 글자 두껍게
                        decoration: event.isCompleted
                            ? TextDecoration.lineThrough
                            : null, // 완료된 일정에 취소선 추가
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                event.time,
                style: TextStyle(
                  fontSize: 14.0, // 시간 텍스트 크기
                  color: Colors.grey[700], // 시간 텍스트 색상
                ),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    showDialog(
                      context: context,
                      builder: (context) => EventModal(
                        selectedDate: selectedDay!,
                        initialValue: event.name,
                        initialTime: event.time,
                        editMode: true,
                        onEventAdded: (updatedEvent, updatedTime) {
                          editEvent(index, updatedEvent, updatedTime); // 수정된 이벤트와 시간 전달
                        },
                      ),
                    );
                  } else if (value == 'delete') {
                    deleteEvent(index);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('수정'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('삭제'),
                    ),
                  ];
                },
              ),
            ),
          );
        },
      )
          : const Center(
        child: Text(
          '선택된 날짜에 일정이 없습니다.',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
