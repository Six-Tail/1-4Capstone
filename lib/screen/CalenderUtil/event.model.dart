// event.model.dart
// 이벤트 아이템
class Event {
  String name;
  String time;
  DateTime startDate;
  DateTime endDate;
  bool isCompleted;

  Event({
    required this.name,
    required this.time,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
  });
}



