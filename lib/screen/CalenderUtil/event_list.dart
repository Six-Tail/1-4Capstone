import 'package:flutter/material.dart';

import 'event.modal.dart';
import 'event.model.dart';

class EventList extends StatelessWidget {
  final DateTime? selectedDay;
  final Map<DateTime, List<Event>> events;
  final Function(
      int index,
      String updatedEvent,
      String updatedTime,
      DateTime updatedStartDate,
      DateTime updatedEndDate,
      String repeat) editEvent;
  final Function(int index) deleteEvent;
  final Function(int index, bool isCompleted) toggleEventCompletion;

  const EventList({
    super.key,
    required this.selectedDay,
    required this.events,
    required this.editEvent,
    required this.deleteEvent,
    required this.toggleEventCompletion,
  });

  @override
  Widget build(BuildContext context) {
    List<Event> selectedEvents =
        (selectedDay != null) ? events[selectedDay!.toUtc()] ?? [] : [];

    final List<PopupMenuEntry<String>> menuItems = [
      const PopupMenuItem<String>(
        value: 'edit',
        child: Text(
          '수정',
          style: TextStyle(
            fontWeight: FontWeight.bold,  // 볼드체 설정
            color: Colors.black,          // 검정색 텍스트 색상
          ),
        ),
      ),
      const PopupMenuItem<String>(
        value: 'delete',
        child: Text(
          '삭제',
          style: TextStyle(
            fontWeight: FontWeight.bold,  // 볼드체 설정
            color: Colors.red,            // 빨간색 텍스트 색상
          ),
        ),
      ),
    ];

    return Expanded(
      child: selectedDay != null && selectedEvents.isNotEmpty
          ? ListView.builder(
              itemCount: selectedEvents.length,
              itemBuilder: (context, index) {
                Event event = selectedEvents[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    title: Row(
                      children: [
                        Checkbox(
                          value: event.isCompleted,
                          onChanged: (bool? value) {
                            int eventIndex = selectedEvents.indexOf(event);
                            toggleEventCompletion(eventIndex, value ?? false);
                          },
                          activeColor: Colors.black,
                          checkColor: Colors.white,
                        ),
                        Expanded(
                          child: Text(
                            event.name,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              decoration: event.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      event.time,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        final eventIndex = selectedEvents.indexOf(event);
                        if (value == 'edit') {
                          showDialog(
                            context: context,
                            builder: (context) => EventModal(
                              selectedDate: selectedDay!,
                              initialValue: event.name,
                              initialTime: event.time,
                              editMode: true,
                              onSave: (updatedEvent, updatedTime, updatedStartDate, updatedEndDate, repeat, repeatCount, selectedDays, selectedDaysInMonth, selectedMonths) {
                                // 인덱스를 추가하여 editEvent 호출
                                editEvent(eventIndex, updatedEvent, updatedTime, updatedStartDate, updatedEndDate, repeat);
                              },
                            ),
                          );
                        } else if (value == 'delete') {
                          deleteEvent(eventIndex);
                        }
                      },
                      itemBuilder: (BuildContext context) => menuItems,
                      color: const Color(0xffcae1f6),
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
