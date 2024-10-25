import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Event {
  String id; // Firestore 문서 ID 추가
  String name;
  String time;
  DateTime startDate;
  DateTime endDate;
  String repeat;
  bool isCompleted;
  int repeatCount;
  String? uid;

  Event({
    required this.id, // 생성자에서 ID 필드 추가
    required this.name,
    required this.time,
    required this.startDate,
    required this.endDate,
    required this.repeat,
    this.isCompleted = false,
    this.repeatCount = 1,
    String? uid,
  }) : uid = uid ?? FirebaseAuth.instance.currentUser?.uid;

  // Firestore로 변환하기 위한 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'time': time,
      'startDate': startDate,
      'endDate': endDate,
      'repeat': repeat,
      'isCompleted': isCompleted,
      'repeatCount': repeatCount,
      if (uid != null) 'uid': uid,
    };
  }

  // Firestore에서 데이터를 받아오는 메서드
  factory Event.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Event(
      id: documentId, // 문서 ID 설정
      name: data['name'],
      time: data['time'],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      repeat: data['repeat'],
      isCompleted: data['isCompleted'] ?? false,
      repeatCount: data['repeatCount'] ?? 1,
      uid: data['uid'],
    );
  }
}
