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

// Firestore에 저장할 수 있도록 Map 형태로 변환하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'time': time,
      'startDate': startDate,
      'endDate': endDate,
      'isCompleted': isCompleted,
    };
  }
}
