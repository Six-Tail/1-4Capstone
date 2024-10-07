// 이벤트 아이템
class Event {
  String name;
  String time;
  bool isCompleted;

  Event({required this.name, required this.time, this.isCompleted = false});
}
