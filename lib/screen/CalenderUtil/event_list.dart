import 'package:flutter/material.dart';
import 'event.modal.dart';
import 'event.model.dart';

class EventList extends StatelessWidget {
  final DateTime? selectedDay;
  final Map<DateTime, List<Event>> events; // 전체 이벤트를 받음
  final Function(int index, String updatedEvent, String updatedTime,
      DateTime updatedStartDate, DateTime updatedEndDate) editEvent;
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
    List<Event> selectedEvents = events[selectedDay!] ?? []; // 선택된 날짜의 이벤트만 가져옴

    return Expanded(
      child: selectedDay != null && selectedEvents.isNotEmpty
          ? ListView.builder(
        itemCount: selectedEvents.length,
        itemBuilder: (context, index) {
          Event event = selectedEvents[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
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
                      toggleEventCompletion(index, value ?? false);
                    },
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
                  if (value == 'edit') {
                    showDialog(
                      context: context,
                      builder: (context) => EventModal(
                        selectedDate: selectedDay!,
                        initialValue: event.name,
                        initialTime: event.time,
                        editMode: true,
                        onSave: (updatedEvent, updatedTime, updatedStartDate, updatedEndDate) {
                          editEvent(index, updatedEvent, updatedTime, updatedStartDate, updatedEndDate);
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
