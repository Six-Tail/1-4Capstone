// event.model.dart
// 이벤트 아이템
import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String name;
  String time;
  DateTime startDate;
  DateTime endDate;
  String repeat;
  final bool isCompleted; // 이벤트 완료 여부를 저장하는 필드

  Event({
    required this.name,
    required this.time,
    required this.startDate,
    required this.endDate,
    required this.repeat,
    this.isCompleted = false, // 기본값은 false로 설정
  });

  // Firestore로 변환하기 위한 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'time': time,
      'startDate': startDate,
      'endDate': endDate,
      'repeat': repeat,
      'isCompleted': isCompleted, // Firestore에 완료 상태도 저장
    };
  }

  // Firestore에서 데이터를 받아오는 메서드 (선택 사항)
  factory Event.fromFirestore(Map<String, dynamic> data) {
    return Event(
      name: data['name'],
      time: data['time'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      repeat: data['repeat'],
      isCompleted: data['isCompleted'] ?? false, // Firestore에서 완료 여부를 가져옴
    );
  }
}

