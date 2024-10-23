// event.model.dart
// 이벤트 아이템
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String name;
  String time;
  DateTime startDate;
  DateTime endDate;
  String repeat;
  final bool isCompleted;
  int repeatCount; // 반복 횟수 추가

  Event({
    required this.name,
    required this.time,
    required this.startDate,
    required this.endDate,
    required this.repeat,
    this.isCompleted = false,
    this.repeatCount = 1, // 기본 반복 횟수 1
  });

  // Firestore로 변환하기 위한 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'time': time,
      'startDate': startDate,
      'endDate': endDate,
      'repeat': repeat,
      'isCompleted': isCompleted,
      'repeatCount': repeatCount, // Firestore에 반복 횟수 저장
    };
  }

  // Firestore에서 데이터를 받아오는 메서드
  factory Event.fromFirestore(Map<String, dynamic> data) {
    return Event(
      name: data['name'],
      time: data['time'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      repeat: data['repeat'],
      isCompleted: data['isCompleted'] ?? false,
      repeatCount: data['repeatCount'] ?? 1, // Firestore에서 반복 횟수 가져옴
    );
  }
}
